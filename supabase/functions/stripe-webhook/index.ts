import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Stripe from 'https://esm.sh/stripe@14?target=deno';

const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? '';
const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

Deno.serve(async (req) => {
  if (!stripeSecretKey || !stripeWebhookSecret) {
    return new Response('Stripe not configured', { status: 503 });
  }

  const signature = req.headers.get('stripe-signature');
  if (!signature) {
    return new Response('Missing signature', { status: 400 });
  }

  const body = await req.text();
  const stripe = new Stripe(stripeSecretKey, { apiVersion: '2023-10-16' });

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, signature, stripeWebhookSecret);
  } catch (err) {
    return new Response(`Webhook signature verification failed: ${err}`, { status: 400 });
  }

  if (event.type === 'payment_intent.succeeded') {
    const intent = event.data.object as Stripe.PaymentIntent;
    const userId = intent.metadata.user_id;
    const coins = parseInt(intent.metadata.coins ?? '0');
    const purchaseId = intent.metadata.purchase_id;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Atomic coin credit via existing function
    await supabase.rpc('topup_coins', {
      p_user_id: userId,
      p_coins: coins,
      p_amount_ils: intent.amount / 100,
      p_payment_method: 'stripe',
    });

    // Mark purchase as completed
    if (purchaseId) {
      await supabase
        .from('real_money_purchases')
        .update({ status: 'completed', completed_at: new Date().toISOString() })
        .eq('id', purchaseId);
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
