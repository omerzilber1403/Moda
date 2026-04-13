import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const fcmServerKey = Deno.env.get('FCM_SERVER_KEY') ?? '';

interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const payload: NotificationPayload = await req.json();
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch FCM tokens for this user
    const { data: tokens } = await supabase
      .from('fcm_tokens')
      .select('token, platform')
      .eq('user_id', payload.userId);

    if (!tokens || tokens.length === 0) {
      return new Response(JSON.stringify({ sent: 0, reason: 'no_tokens' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Send via FCM Legacy HTTP API
    if (!fcmServerKey) {
      console.warn('FCM_SERVER_KEY not set — notification skipped');
      return new Response(JSON.stringify({ sent: 0, reason: 'fcm_key_missing' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const results = await Promise.allSettled(
      tokens.map(({ token }) =>
        fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `key=${fcmServerKey}`,
          },
          body: JSON.stringify({
            to: token,
            notification: { title: payload.title, body: payload.body },
            data: payload.data ?? {},
          }),
        })
      )
    );

    const sent = results.filter((r) => r.status === 'fulfilled').length;
    return new Response(JSON.stringify({ sent }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
