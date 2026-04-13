// Apply the chat fix migrations directly to Supabase
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: './server/.env' });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in server/.env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function executeSql(sql) {
  // Use the Supabase REST API to execute raw SQL
  const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec_sql`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': supabaseServiceKey,
      'Authorization': `Bearer ${supabaseServiceKey}`,
      'Prefer': 'return=minimal'
    },
    body: JSON.stringify({ query: sql })
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`HTTP ${response.status}: ${error}`);
  }

  return response;
}

async function applyMigrations() {
  console.log('🔧 Applying chat fix migrations...\n');

  const migrations = [
    './supabase/migrations/20260402000001_add_system_message_to_order_creation.sql',
    './supabase/migrations/20260402000002_chat_helper_rpcs.sql',
  ];

  for (const migrationFile of migrations) {
    const sql = fs.readFileSync(migrationFile, 'utf8');
    const migrationName = path.basename(migrationFile);
    
    console.log(`📄 Applying ${migrationName}...`);
    
    try {
      // Execute SQL directly using the admin API
      const { data, error } = await supabase.rpc('exec_sql', { query: sql });
      
      if (error) {
        console.log(`  ⚠️  Standard RPC failed: ${error.message}`);
        console.log('  💡 Copy the SQL from the migration file and paste it into Supabase Dashboard > SQL Editor');
        console.log(`     File: ${migrationFile}\n`);
      } else {
        console.log(`  ✅ ${migrationName} applied successfully!`);
      }
    } catch (err) {
      console.error(`  ❌ Error: ${err.message}`);
      console.log('  💡 Copy the SQL from the migration file and paste it into Supabase Dashboard > SQL Editor');
      console.log(`     File: ${migrationFile}\n`);
    }
  }

  // Change Dana's password
  console.log('\n🔐 Changing Dana\'s password...\n');
  
  try {
    // First, get Dana's user ID
    const { data: users, error: findError } = await supabase
      .from('profiles')
      .select('id, email, full_name')
      .eq('email', 'dana@moda.com')
      .single();

    if (findError || !users) {
      console.error('  ❌ Could not find Dana\'s profile');
      console.log('  💡 Please change password manually in Supabase Dashboard > Authentication');
    } else {
      console.log(`  ℹ️  Found Dana: ${users.full_name} (${users.email})`);
      
      // Update auth password using admin API
      const { data: updateData, error: updateError } = await supabase.auth.admin.updateUserById(
        users.id,
        { password: 'Moda2026' }
      );

      if (updateError) {
        console.error(`  ❌ Error updating password: ${updateError.message}`);
        console.log('  💡 Please change password manually in Supabase Dashboard > Authentication > Users');
      } else {
        console.log('  ✅ Password changed to: Moda2026');
      }
    }
  } catch (err) {
    console.error(`  ❌ Error: ${err.message}`);
    console.log('  💡 Please change password manually in Supabase Dashboard > Authentication > Users');
  }

  console.log('\n✨ Complete!\n');
  console.log('Next steps:');
  console.log('1. If any migrations failed, apply them manually via Supabase Dashboard');
  console.log('2. Test login as Dana with password: Moda2026');
  console.log('3. Make a purchase and check the Inbox tab');
}

applyMigrations().catch(console.error);
