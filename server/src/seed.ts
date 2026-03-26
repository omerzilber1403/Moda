import pool from './db';
import bcrypt from 'bcrypt';

// ---------------------------------------------------------------------------
// Fixed UUIDs
// ---------------------------------------------------------------------------
const USER_ME   = '00000000-0000-0000-0000-000000000001';
const USER_2    = '00000000-0000-0000-0000-000000000002';
const USER_3    = '00000000-0000-0000-0000-000000000003';
const USER_4    = '00000000-0000-0000-0000-000000000004';
const USER_5    = '00000000-0000-0000-0000-000000000005';
const USER_6    = '00000000-0000-0000-0000-000000000006';

const MATCH_1   = '20000000-0000-0000-0000-000000000001';
const MATCH_2   = '20000000-0000-0000-0000-000000000002';

function itemId(n: number): string {
  return `10000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
}

function img(seed: string): string {
  return `https://picsum.photos/seed/${seed}/400/600`;
}

// ---------------------------------------------------------------------------
// Users
// ---------------------------------------------------------------------------
interface UserRow {
  id: string;
  email: string;
  display_name: string;
  city: string;
  bio: string;
  avatar_url: string;
}

const users: UserRow[] = [
  { id: USER_ME, email: 'me@fitflip.com',     display_name: 'Alex Rivera',  city: 'Tel Aviv',  bio: 'Fashion lover, sustainable style advocate',      avatar_url: 'https://picsum.photos/seed/avatar-me/300/300' },
  { id: USER_2,  email: 'maya@example.com',    display_name: 'Maya Cohen',   city: 'Haifa',     bio: 'Vintage collector & thrift queen',                avatar_url: 'https://picsum.photos/seed/avatar-maya/300/300' },
  { id: USER_3,  email: 'liam@example.com',    display_name: 'Liam Katz',    city: 'Jerusalem', bio: 'Streetwear enthusiast',                           avatar_url: 'https://picsum.photos/seed/avatar-liam/300/300' },
  { id: USER_4,  email: 'noa@example.com',     display_name: 'Noa Shapiro',  city: 'Tel Aviv',  bio: 'Minimalist wardrobe, maximal style',              avatar_url: 'https://picsum.photos/seed/avatar-noa/300/300' },
  { id: USER_5,  email: 'eden@example.com',    display_name: 'Eden Levy',    city: 'Ramat Gan', bio: 'Y2K fashion revivalist',                          avatar_url: 'https://picsum.photos/seed/avatar-eden/300/300' },
  { id: USER_6,  email: 'yoav@example.com',    display_name: 'Yoav Ben-Ari', city: 'Netanya',   bio: 'Sneakerhead & denim collector',                   avatar_url: 'https://picsum.photos/seed/avatar-yoav/300/300' },
];

// ---------------------------------------------------------------------------
// Clothing items
// ---------------------------------------------------------------------------
interface ItemRow {
  n: number;
  owner_id: string;
  title: string;
  brand: string;
  size: string | null;
  clothing_type: string;
  category_id: number;
  condition: string;
  color: string;
  description: string;
  attributes: Record<string, string | number>;
  images: string[];
}

const items: ItemRow[] = [
  // --- TOPS (category 1) ---
  { n: 1,  owner_id: USER_2, title: 'Vintage Band Tee',       brand: 'Hanes',           size: 'M',  clothing_type: 'top',       category_id: 1, condition: 'good',          color: 'Black',       description: 'Authentic 90s tour tee, perfectly faded.',              attributes: { sleeve: 'Short', collar: 'Crew', fit: 'Regular' },   images: [img('bandtee'), img('extra1')] },
  { n: 2,  owner_id: USER_3, title: 'Supreme Box Logo Hoodie', brand: 'Supreme',         size: 'L',  clothing_type: 'top',       category_id: 1, condition: 'good',          color: 'Black',       description: 'Classic box logo hoodie in great shape.',               attributes: { sleeve: 'Long', collar: 'Hoodie', fit: 'Oversized' }, images: [img('supremehoodie'), img('extra2')] },
  { n: 3,  owner_id: USER_4, title: 'Silk Button-Up Blouse',   brand: 'COS',             size: 'S',  clothing_type: 'top',       category_id: 1, condition: 'like_new',      color: 'Cream',       description: 'Elegant silk blouse, perfect for layering.',            attributes: { sleeve: 'Long', collar: 'Button-Up', fit: 'Regular' }, images: [img('silkblouse'), img('extra3')] },
  { n: 4,  owner_id: USER_5, title: 'Cropped Baby Tee',        brand: 'Brandy Melville', size: 'S',  clothing_type: 'top',       category_id: 1, condition: 'good',          color: 'White',       description: 'Y2K cropped baby tee, super soft cotton.',              attributes: { sleeve: 'Short', collar: 'Crew', fit: 'Cropped' },   images: [img('croptee'), img('extra4')] },
  { n: 5,  owner_id: USER_6, title: 'Flannel Shirt',           brand: 'Patagonia',       size: 'L',  clothing_type: 'top',       category_id: 1, condition: 'good',          color: 'Red Plaid',   description: 'Heavy-weight organic cotton flannel.',                  attributes: { sleeve: 'Long', collar: 'Button-Up', fit: 'Regular' }, images: [img('flannel1'), img('extra5')] },
  { n: 6,  owner_id: USER_3, title: 'Oversized Graphic Tee',   brand: 'Uniqlo',          size: 'XL', clothing_type: 'top',       category_id: 1, condition: 'good',          color: 'Gray',        description: 'Oversized boxy fit with abstract print.',               attributes: { sleeve: 'Short', collar: 'Crew', fit: 'Boxy' },      images: [img('graphictee'), img('extra6')] },
  { n: 7,  owner_id: USER_2, title: 'Cashmere Turtleneck',     brand: 'Everlane',        size: 'M',  clothing_type: 'top',       category_id: 1, condition: 'like_new',      color: 'Oatmeal',     description: 'Luxurious cashmere, barely worn.',                      attributes: { sleeve: 'Long', collar: 'Turtleneck', fit: 'Slim' }, images: [img('cashmere'), img('extra7')] },
  { n: 8,  owner_id: USER_5, title: 'Polo Crop Top',           brand: 'Ralph Lauren',    size: 'S',  clothing_type: 'top',       category_id: 1, condition: 'like_new',      color: 'Navy',        description: 'Vintage polo, cropped and hemmed.',                     attributes: { sleeve: 'Short', collar: 'Polo', fit: 'Cropped' },   images: [img('polocrop'), img('extra8')] },

  // --- BOTTOMS (category 2) ---
  { n: 9,  owner_id: USER_3, title: 'Cargo Pants',             brand: 'Carhartt WIP',    size: 'M',  clothing_type: 'bottom',    category_id: 2, condition: 'like_new',      color: 'Khaki',       description: 'Relaxed fit cargo with big pockets.',                   attributes: { cut: 'Relaxed', rise: 'Mid', inseam: 'Regular' },    images: [img('cargo1'), img('extra9')] },
  { n: 10, owner_id: USER_4, title: 'High-Waist Straight Jeans', brand: 'Everlane',      size: 'S',  clothing_type: 'bottom',    category_id: 2, condition: 'good',          color: 'Dark Blue',   description: 'Classic straight leg with high rise.',                  attributes: { cut: 'Straight', rise: 'High', inseam: 'Regular' },  images: [img('straightjeans'), img('extra10')] },
  { n: 11, owner_id: USER_6, title: 'Slim Chinos',             brand: 'Dockers',         size: 'L',  clothing_type: 'bottom',    category_id: 2, condition: 'good',          color: 'Navy',        description: 'Versatile slim-fit chinos for any occasion.',           attributes: { cut: 'Slim', rise: 'Mid', inseam: 'Regular' },       images: [img('chinos1'), img('extra11')] },
  { n: 12, owner_id: USER_5, title: 'Pleated Mini Skirt',      brand: 'H&M',             size: 'M',  clothing_type: 'bottom',    category_id: 2, condition: 'new_with_tags', color: 'Pink',        description: 'Adorable pleated skirt, never worn.',                   attributes: { cut: 'Flare', rise: 'High', inseam: 'Short' },       images: [img('skirt1'), img('extra12')] },
  { n: 13, owner_id: USER_2, title: 'Wide Leg Linen Pants',    brand: 'Zara',            size: 'M',  clothing_type: 'bottom',    category_id: 2, condition: 'like_new',      color: 'Beige',       description: 'Breezy linen wide legs, perfect for summer.',           attributes: { cut: 'Wide', rise: 'High', inseam: 'Long' },         images: [img('linenpants'), img('extra13')] },
  { n: 14, owner_id: USER_3, title: 'Skinny Black Jeans',      brand: "Levi's",          size: 'M',  clothing_type: 'bottom',    category_id: 2, condition: 'good',          color: 'Black',       description: 'Classic 510 skinny fit in jet black.',                  attributes: { cut: 'Skinny', rise: 'Mid', inseam: 'Regular' },     images: [img('skinnyjeans2'), img('extra14')] },
  { n: 15, owner_id: USER_6, title: 'Bootcut Corduroy',        brand: 'Wrangler',        size: 'L',  clothing_type: 'bottom',    category_id: 2, condition: 'fair',          color: 'Brown',       description: 'Retro corduroy bootcut, minor fading.',                 attributes: { cut: 'Bootcut', rise: 'Mid', inseam: 'Long' },       images: [img('corduroy'), img('extra15')] },

  // --- DRESSES (category 3) ---
  { n: 16, owner_id: USER_2, title: 'Floral Midi Wrap Dress',  brand: 'Zara',            size: 'S',  clothing_type: 'dress',     category_id: 3, condition: 'good',          color: 'Multi',       description: 'Beautiful floral wrap dress, midi length.',             attributes: { length: 'Midi', sleeve: 'Short', style: 'Wrap' },    images: [img('floraldress'), img('extra16')] },
  { n: 17, owner_id: USER_4, title: 'Black Cocktail Dress',    brand: 'Massimo Dutti',   size: 'S',  clothing_type: 'dress',     category_id: 3, condition: 'like_new',      color: 'Black',       description: 'Sleek cocktail dress, worn once.',                      attributes: { length: 'Mini', sleeve: 'Sleeveless', style: 'Cocktail' }, images: [img('cocktaildress'), img('extra17')] },
  { n: 18, owner_id: USER_4, title: 'Boho Maxi Dress',         brand: 'Free People',     size: 'M',  clothing_type: 'dress',     category_id: 3, condition: 'good',          color: 'Terracotta',  description: 'Flowy bohemian maxi with beautiful details.',           attributes: { length: 'Maxi', sleeve: 'Long', style: 'Boho' },    images: [img('bohodress'), img('extra18')] },
  { n: 19, owner_id: USER_2, title: 'Casual Shirt Dress',      brand: 'GAP',             size: 'M',  clothing_type: 'dress',     category_id: 3, condition: 'good',          color: 'Denim Blue',  description: 'Easy-going denim shirt dress for everyday.',            attributes: { length: 'Midi', sleeve: 'Short', style: 'Shirt' },   images: [img('shirtdress'), img('extra19')] },

  // --- OUTERWEAR (category 4) ---
  { n: 20, owner_id: USER_2, title: 'Vintage Denim Jacket',    brand: "Levi's",          size: 'M',  clothing_type: 'outerwear', category_id: 4, condition: 'like_new',      color: 'Blue',        description: 'Classic trucker jacket with beautiful patina.',          attributes: { style: 'Jacket', fill_weight: 'Light' },             images: [img('denimjacket'), img('extra20')] },
  { n: 21, owner_id: USER_4, title: 'Camel Wool Coat',         brand: 'Max Mara',        size: 'S',  clothing_type: 'outerwear', category_id: 4, condition: 'like_new',      color: 'Camel',       description: 'Investment piece, timeless camel coat.',                attributes: { style: 'Coat', fill_weight: 'Heavy' },               images: [img('woolcoat'), img('extra21')] },
  { n: 22, owner_id: USER_6, title: 'Puffer Vest',             brand: 'The North Face',  size: 'L',  clothing_type: 'outerwear', category_id: 4, condition: 'like_new',      color: 'Black',       description: 'Lightweight 700-fill puffer vest.',                     attributes: { style: 'Vest', fill_weight: 'Medium' },              images: [img('puffervest'), img('extra22')] },
  { n: 23, owner_id: USER_3, title: 'Bomber Jacket',           brand: 'Alpha Industries', size: 'M', clothing_type: 'outerwear', category_id: 4, condition: 'good',          color: 'Olive',       description: 'MA-1 bomber, iconic streetwear silhouette.',            attributes: { style: 'Bomber', fill_weight: 'Medium' },            images: [img('bomber'), img('extra23')] },
  { n: 24, owner_id: USER_5, title: 'Cropped Blazer',          brand: 'Mango',           size: 'S',  clothing_type: 'outerwear', category_id: 4, condition: 'new_with_tags', color: 'Black',       description: 'Structured cropped blazer, brand new.',                 attributes: { style: 'Blazer', fill_weight: 'Light' },             images: [img('blazer'), img('extra24')] },

  // --- SHOES (category 5) ---
  { n: 25, owner_id: USER_2, title: 'White Leather Sneakers',  brand: 'Nike',            size: null, clothing_type: 'shoes',     category_id: 5, condition: 'like_new',      color: 'White',       description: 'Air Force 1 lows, barely worn.',                        attributes: { shoe_size: 40, style: 'Sneakers' },                  images: [img('af1'), img('extra25')] },
  { n: 26, owner_id: USER_5, title: 'Platform Combat Boots',   brand: 'Dr. Martens',     size: null, clothing_type: 'shoes',     category_id: 5, condition: 'good',          color: 'Black',       description: 'Jadon platform boots, fully broken in.',                attributes: { shoe_size: 38, style: 'Boots' },                     images: [img('combatboots'), img('extra26')] },
  { n: 27, owner_id: USER_3, title: 'New Balance 550',         brand: 'New Balance',     size: null, clothing_type: 'shoes',     category_id: 5, condition: 'like_new',      color: 'White/Green', description: 'Clean retro basketball silhouette.',                    attributes: { shoe_size: 42, style: 'Sneakers' },                  images: [img('nb550'), img('extra27')] },
  { n: 28, owner_id: USER_6, title: 'Chelsea Boots',           brand: 'Blundstone',      size: null, clothing_type: 'shoes',     category_id: 5, condition: 'good',          color: 'Brown',       description: 'Classic pull-on Chelsea boots.',                        attributes: { shoe_size: 43, style: 'Boots' },                     images: [img('chelsea'), img('extra28')] },
  { n: 29, owner_id: USER_4, title: 'Strappy Heeled Sandals',  brand: 'Steve Madden',    size: null, clothing_type: 'shoes',     category_id: 5, condition: 'like_new',      color: 'Black',       description: 'Elegant block heel sandals.',                           attributes: { shoe_size: 37, style: 'Heels' },                     images: [img('heels1'), img('extra29')] },

  // --- ACCESSORIES (category 6) ---
  { n: 30, owner_id: USER_5, title: 'Gold Chain Necklace',     brand: 'Mejuri',          size: null, clothing_type: 'accessory', category_id: 6, condition: 'like_new',      color: 'Gold',        description: 'Dainty 14k gold-plated chain.',                         attributes: { style: 'Necklace' },                                 images: [img('goldchain'), img('extra30')] },
  { n: 31, owner_id: USER_2, title: 'Leather Belt',            brand: 'Uniqlo',          size: null, clothing_type: 'accessory', category_id: 6, condition: 'good',          color: 'Brown',       description: 'Genuine leather belt, versatile.',                      attributes: { style: 'Belt' },                                     images: [img('belt1'), img('extra31')] },
  { n: 32, owner_id: USER_6, title: 'Snapback Cap',            brand: 'New Era',         size: null, clothing_type: 'accessory', category_id: 6, condition: 'good',          color: 'Black',       description: 'Classic snapback, adjustable.',                         attributes: { style: 'Hat' },                                      images: [img('snapback'), img('extra32')] },
  { n: 33, owner_id: USER_3, title: 'Canvas Backpack',         brand: 'Fjallraven',      size: null, clothing_type: 'accessory', category_id: 6, condition: 'like_new',      color: 'Navy',        description: 'Kanken classic, barely used.',                           attributes: { style: 'Backpack' },                                 images: [img('kanken'), img('extra33')] },

  // --- USER-ME ITEMS ---
  { n: 34, owner_id: USER_ME, title: 'Striped Breton Tee',     brand: 'Muji',            size: 'M',  clothing_type: 'top',       category_id: 1, condition: 'good',          color: 'Navy/White',  description: 'Classic Breton stripe, organic cotton.',                attributes: { sleeve: 'Short', collar: 'Crew', fit: 'Regular' },   images: [img('bretontee'), img('extra34')] },
  { n: 35, owner_id: USER_ME, title: 'Black Skinny Jeans',     brand: "Levi's",          size: 'M',  clothing_type: 'bottom',    category_id: 2, condition: 'good',          color: 'Black',       description: 'Trusty 510s, great condition.',                         attributes: { cut: 'Skinny', rise: 'Mid', inseam: 'Regular' },     images: [img('blackjeans'), img('extra35')] },
  { n: 36, owner_id: USER_ME, title: 'Canvas Tote Bag',        brand: 'Baggu',           size: null, clothing_type: 'accessory', category_id: 6, condition: 'like_new',      color: 'Natural',     description: 'Sturdy canvas tote, everyday carry.',                   attributes: { style: 'Tote' },                                     images: [img('canvastote'), img('extra36')] },
];

// ---------------------------------------------------------------------------
// Seed function
// ---------------------------------------------------------------------------
async function seed(): Promise<void> {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    console.log('Seeding database...');

    // -----------------------------------------------------------------------
    // 1. Clear existing data (FK-safe order)
    // -----------------------------------------------------------------------
    console.log('  Clearing existing data...');
    await client.query('DELETE FROM messages');
    await client.query('DELETE FROM matches');
    await client.query('DELETE FROM swipes');
    await client.query('DELETE FROM clothing_items');
    await client.query('DELETE FROM users');

    // -----------------------------------------------------------------------
    // 2. Insert users
    // -----------------------------------------------------------------------
    console.log('  Inserting 6 users...');
    const passwordHash = await bcrypt.hash('password123', 10);

    for (const u of users) {
      await client.query(
        `INSERT INTO users (id, email, password_hash, display_name, avatar_url, bio, city)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [u.id, u.email, passwordHash, u.display_name, u.avatar_url, u.bio, u.city]
      );
    }

    // -----------------------------------------------------------------------
    // 3. Insert clothing items
    // -----------------------------------------------------------------------
    console.log('  Inserting 36 clothing items...');

    for (const item of items) {
      await client.query(
        `INSERT INTO clothing_items
           (id, owner_id, title, description, brand, size, clothing_type, category_id, condition, color, images, attributes, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, true)`,
        [
          itemId(item.n),
          item.owner_id,
          item.title,
          item.description,
          item.brand,
          item.size,
          item.clothing_type,
          item.category_id,
          item.condition,
          item.color,
          item.images,
          JSON.stringify(item.attributes),
        ]
      );
    }

    // -----------------------------------------------------------------------
    // 4. Insert swipes that produce 2 matches
    // -----------------------------------------------------------------------
    console.log('  Inserting swipes...');

    // user-me swiped RIGHT on item-20 (Vintage Denim Jacket, owner: user-2)
    await client.query(
      `INSERT INTO swipes (swiper_id, item_id, direction) VALUES ($1, $2, 'right')`,
      [USER_ME, itemId(20)]
    );
    // user-2 swiped RIGHT on item-34 (Striped Breton Tee, owner: user-me)
    await client.query(
      `INSERT INTO swipes (swiper_id, item_id, direction) VALUES ($1, $2, 'right')`,
      [USER_2, itemId(34)]
    );
    // user-me swiped RIGHT on item-12 (Pleated Mini Skirt, owner: user-5)
    await client.query(
      `INSERT INTO swipes (swiper_id, item_id, direction) VALUES ($1, $2, 'right')`,
      [USER_ME, itemId(12)]
    );
    // user-5 swiped RIGHT on item-35 (Black Skinny Jeans, owner: user-me)
    await client.query(
      `INSERT INTO swipes (swiper_id, item_id, direction) VALUES ($1, $2, 'right')`,
      [USER_5, itemId(35)]
    );

    // -----------------------------------------------------------------------
    // 5. Insert matches
    // -----------------------------------------------------------------------
    console.log('  Inserting 2 matches...');

    // match-1: user-me <-> user-2 (item-20 denim jacket <-> item-34 breton tee)
    await client.query(
      `INSERT INTO matches (id, user1_id, user2_id, item1_id, item2_id, status)
       VALUES ($1, $2, $3, $4, $5, 'active')`,
      [MATCH_1, USER_ME, USER_2, itemId(20), itemId(34)]
    );
    // match-2: user-me <-> user-5 (item-12 pleated skirt <-> item-35 skinny jeans)
    await client.query(
      `INSERT INTO matches (id, user1_id, user2_id, item1_id, item2_id, status)
       VALUES ($1, $2, $3, $4, $5, 'active')`,
      [MATCH_2, USER_ME, USER_5, itemId(12), itemId(35)]
    );

    // -----------------------------------------------------------------------
    // 6. Insert messages
    // -----------------------------------------------------------------------
    console.log('  Inserting 5 messages...');

    const messages: Array<{ match_id: string; sender_id: string; content: string; created_at: string }> = [
      { match_id: MATCH_1, sender_id: USER_2,  content: 'Hey! Love that striped tee',                                     created_at: '2026-03-18T14:30:00Z' },
      { match_id: MATCH_1, sender_id: USER_ME, content: 'Thanks! Your denim jacket is amazing, where should we meet?',     created_at: '2026-03-18T14:35:00Z' },
      { match_id: MATCH_1, sender_id: USER_2,  content: 'How about Dizengoff Center this Saturday?',                       created_at: '2026-03-18T14:40:00Z' },
      { match_id: MATCH_2, sender_id: USER_5,  content: 'Omg those jeans are exactly what I need!',                        created_at: '2026-03-15T18:00:00Z' },
      { match_id: MATCH_2, sender_id: USER_ME, content: "Yes! I've been eyeing that pleated skirt forever",                created_at: '2026-03-16T10:15:00Z' },
    ];

    for (const msg of messages) {
      await client.query(
        `INSERT INTO messages (match_id, sender_id, content, message_type, created_at)
         VALUES ($1, $2, $3, 'text', $4)`,
        [msg.match_id, msg.sender_id, msg.content, msg.created_at]
      );
    }

    await client.query('COMMIT');
    console.log('Seed completed successfully.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Seed failed, rolled back:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
    process.exit(0);
  }
}

seed();
