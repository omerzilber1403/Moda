import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Stripe from 'https://esm.sh/stripe@14?target=deno';

const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// SC to ILS conversion: 1 SC = 1 ILS
const COIN_TO_AGOROT = 100; // 1 ILS = 100 agorot (Stripe uses smallest currency unit)

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  if (!stripeSecretKey) {
    return new Response(JSON.stringify({ error: 'Stripe not configured' }), {
      status: 503,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  try {
    // Verify the caller is authenticated
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
    }

    const { coins } = await req.json() as { coins: number };
    if (!coins || coins <= 0) {
      return new Response(JSON.stringify({ error: 'Invalid coin amount' }), { status: 400 });
    }

    const stripe = new Stripe(stripeSecretKey, { apiVersion: '2023-10-16' });
    const amountAgorot = coins * COIN_TO_AGOROT;

    // Create pending purchase record
    const { data: purchase } = await supabase
      .from('real_money_purchases')
      .insert({
        user_id: user.id,
        amount_ils: coins,
        coins_purchased: coins,
        payment_method: 'stripe',
        status: 'pending',
      })
      .select()
      .single();

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountAgorot,
      currency: 'ils',
      metadata: {
        user_id: user.id,
        coins: coins.toString(),
        purchase_id: purchase?.id ?? '',
      },
    });

    // Store payment_reference
    if (purchase?.id) {
      await supabase
        .from('real_money_purchases')
        .update({ payment_reference: paymentIntent.id })
        .eq('id', purchase.id);
    }

    return new Response(
      JSON.stringify({ client_secret: paymentIntent.client_secret }),
      { headers: { 'Content-Type': 'application/json' } }
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
