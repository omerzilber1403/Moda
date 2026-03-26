import '../models/models.dart';

/// Mock data layer — replaces real API until backend is ready.
class MockApi {
  static const _currentUserId = 'user-me';

  // Fashion-specific image map (Unsplash) — matches Stitch mockup quality
  static const _fashionImages = <String, String>{
    'bandtee': 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&h=600&fit=crop',
    'supremehoodie': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400&h=600&fit=crop',
    'silkblouse': 'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?w=400&h=600&fit=crop',
    'croptee': 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=400&h=600&fit=crop',
    'flannel1': 'https://images.unsplash.com/photo-1589310243389-96a5483213a8?w=400&h=600&fit=crop',
    'graphictee': 'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?w=400&h=600&fit=crop',
    'cashmere': 'https://images.unsplash.com/photo-1434389677669-e08b4cda3a54?w=400&h=600&fit=crop',
    'polocrop': 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400&h=600&fit=crop',
    'levi501': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&h=600&fit=crop',
    'cargos': 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=600&fit=crop',
    'miniskirt': 'https://images.unsplash.com/photo-1594938298603-c8148c4b4d99?w=400&h=600&fit=crop',
    'slacks': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=600&fit=crop',
    'maxidress': 'https://images.unsplash.com/photo-1572804013427-4d7ca7268217?w=400&h=600&fit=crop',
    'slipDress': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400&h=600&fit=crop',
    'wrapDress': 'https://images.unsplash.com/photo-1566206091558-7f218b696731?w=400&h=600&fit=crop',
    'trenchcoat': 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400&h=600&fit=crop',
    'leatherjacket': 'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?w=400&h=600&fit=crop',
    'puffercoat': 'https://images.unsplash.com/photo-1547043786-de78b713e258?w=400&h=600&fit=crop',
    'airmax': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=600&fit=crop',
    'newbalance': 'https://images.unsplash.com/photo-1539185441755-769473a23570?w=400&h=600&fit=crop',
    'heels': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&h=600&fit=crop',
    'bag': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&h=600&fit=crop',
    'sunglasses': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400&h=600&fit=crop',
    'scarf': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=600&fit=crop',
  };

  static final List<User> users = [
    User(
      id: _currentUserId,
      email: 'me@fitflip.com',
      displayName: 'Alex Rivera',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      bio: 'Fashion lover, sustainable style advocate',
      city: 'Tel Aviv',
      styleCoinBalance: 50,
      createdAt: DateTime(2025, 1, 15),
    ),
    User(
      id: 'user-2',
      email: 'maya@example.com',
      displayName: 'Maya Cohen',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&h=300&fit=crop&crop=face',
      bio: 'Vintage collector & thrift queen',
      city: 'Haifa',
      styleCoinBalance: 120,
      createdAt: DateTime(2025, 2, 10),
    ),
    User(
      id: 'user-3',
      email: 'liam@example.com',
      displayName: 'Liam Katz',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop&crop=face',
      bio: 'Streetwear enthusiast',
      city: 'Jerusalem',
      styleCoinBalance: 30,
      createdAt: DateTime(2025, 3, 1),
    ),
    User(
      id: 'user-4',
      email: 'noa@example.com',
      displayName: 'Noa Shapiro',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
      bio: 'Minimalist wardrobe, maximal style',
      city: 'Tel Aviv',
      styleCoinBalance: 200,
      createdAt: DateTime(2025, 1, 28),
    ),
    User(
      id: 'user-5',
      email: 'eden@example.com',
      displayName: 'Eden Levy',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop&crop=face',
      bio: 'Y2K fashion revivalist',
      city: 'Ramat Gan',
      styleCoinBalance: 75,
      createdAt: DateTime(2025, 4, 5),
    ),
    User(
      id: 'user-6',
      email: 'yoav@example.com',
      displayName: 'Yoav Ben-Ari',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
      bio: 'Sneakerhead & denim collector',
      city: 'Netanya',
      styleCoinBalance: 15,
      createdAt: DateTime(2025, 2, 20),
    ),
  ];

  static const List<Category> categories = [
    Category(id: 1, name: 'Tops', slug: 'tops', icon: '\u{1F455}'),
    Category(id: 2, name: 'Bottoms', slug: 'bottoms', icon: '\u{1F456}'),
    Category(id: 3, name: 'Dresses', slug: 'dresses', icon: '\u{1F457}'),
    Category(id: 4, name: 'Outerwear', slug: 'outerwear', icon: '\u{1F9E5}'),
    Category(id: 5, name: 'Shoes', slug: 'shoes', icon: '\u{1F45F}'),
    Category(id: 6, name: 'Accessories', slug: 'accessories', icon: '\u{1F392}'),
  ];

  static final List<ClothingItem> items = _generateItems();

  static List<ClothingItem> _generateItems() {
    int idx = 0;
    String id() => 'item-${++idx}';
    String img(String seed) =>
        _fashionImages[seed] ?? 'https://picsum.photos/seed/$seed/400/600';
    String extra(int i) => 'https://picsum.photos/seed/extra$i/400/600';

    return [
      // ──── TOPS (8) ────
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'Vintage Band Tee',
        brand: 'Hanes', size: 'M', clothingType: ClothingType.top,
        categoryId: 1, condition: 'good', color: 'Black',
        description: 'Authentic 90s tour tee, perfectly faded.',
        priceInCoins: 35,
        isActive: false, // sold
        attributes: {'sleeve': 'Short', 'collar': 'Crew', 'fit': 'Regular'},
        images: [img('bandtee'), extra(idx)], createdAt: DateTime(2025, 3, 5),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'Supreme Box Logo Hoodie',
        brand: 'Supreme', size: 'L', clothingType: ClothingType.top,
        categoryId: 1, condition: 'good', color: 'Black',
        description: 'Classic box logo hoodie in great shape.',
        priceInCoins: 45,
        attributes: {'sleeve': 'Long', 'collar': 'Hoodie', 'fit': 'Oversized'},
        images: [img('supremehoodie'), extra(idx)], createdAt: DateTime(2025, 4, 12),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'Silk Button-Up Blouse',
        brand: 'COS', size: 'S', clothingType: ClothingType.top,
        categoryId: 1, condition: 'like_new', color: 'Cream',
        description: 'Elegant silk blouse, perfect for layering.',
        priceInCoins: 40,
        attributes: {'sleeve': 'Long', 'collar': 'Button-Up', 'fit': 'Regular'},
        images: [img('silkblouse'), extra(idx)], createdAt: DateTime(2025, 2, 18),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-5', title: 'Cropped Baby Tee',
        brand: 'Brandy Melville', size: 'S', clothingType: ClothingType.top,
        categoryId: 1, condition: 'good', color: 'White',
        description: 'Y2K cropped baby tee, super soft cotton.',
        priceInCoins: 20,
        attributes: {'sleeve': 'Short', 'collar': 'Crew', 'fit': 'Cropped'},
        images: [img('croptee'), extra(idx)], createdAt: DateTime(2025, 5, 1),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-6', title: 'Flannel Shirt',
        brand: 'Patagonia', size: 'L', clothingType: ClothingType.top,
        categoryId: 1, condition: 'good', color: 'Red Plaid',
        description: 'Heavy-weight organic cotton flannel.',
        priceInCoins: 30,
        attributes: {'sleeve': 'Long', 'collar': 'Button-Up', 'fit': 'Regular'},
        images: [img('flannel1'), extra(idx)], createdAt: DateTime(2025, 6, 10),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'Oversized Graphic Tee',
        brand: 'Uniqlo', size: 'XL', clothingType: ClothingType.top,
        categoryId: 1, condition: 'good', color: 'Gray',
        description: 'Oversized boxy fit with abstract print.',
        priceInCoins: 25,
        attributes: {'sleeve': 'Short', 'collar': 'Crew', 'fit': 'Boxy'},
        images: [img('graphictee'), extra(idx)], createdAt: DateTime(2025, 7, 3),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'Cashmere Turtleneck',
        brand: 'Everlane', size: 'M', clothingType: ClothingType.top,
        categoryId: 1, condition: 'like_new', color: 'Oatmeal',
        description: 'Luxurious cashmere, barely worn.',
        priceInCoins: 45,
        attributes: {'sleeve': 'Long', 'collar': 'Turtleneck', 'fit': 'Slim'},
        images: [img('cashmere'), extra(idx)], createdAt: DateTime(2025, 1, 20),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-5', title: 'Polo Crop Top',
        brand: 'Ralph Lauren', size: 'S', clothingType: ClothingType.top,
        categoryId: 1, condition: 'like_new', color: 'Navy',
        description: 'Vintage polo, cropped and hemmed.',
        priceInCoins: 30,
        attributes: {'sleeve': 'Short', 'collar': 'Polo', 'fit': 'Cropped'},
        images: [img('polocrop'), extra(idx)], createdAt: DateTime(2025, 8, 14),
      ),

      // ──── BOTTOMS (7) ────
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'Cargo Pants',
        brand: 'Carhartt WIP', size: 'M', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'like_new', color: 'Khaki',
        description: 'Relaxed fit cargo with big pockets.',
        priceInCoins: 40,
        attributes: {'cut': 'Relaxed', 'rise': 'Mid', 'inseam': 'Regular'},
        images: [img('cargo1'), extra(idx)], createdAt: DateTime(2025, 3, 15),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'High-Waist Straight Jeans',
        brand: 'Everlane', size: 'S', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'good', color: 'Dark Blue',
        description: 'Classic straight leg with high rise.',
        priceInCoins: 35,
        attributes: {'cut': 'Straight', 'rise': 'High', 'inseam': 'Regular'},
        images: [img('straightjeans'), extra(idx)], createdAt: DateTime(2025, 2, 22),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-6', title: 'Slim Chinos',
        brand: 'Dockers', size: 'L', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'good', color: 'Navy',
        description: 'Versatile slim-fit chinos for any occasion.',
        priceInCoins: 30,
        attributes: {'cut': 'Slim', 'rise': 'Mid', 'inseam': 'Regular'},
        images: [img('chinos1'), extra(idx)], createdAt: DateTime(2025, 4, 8),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-5', title: 'Pleated Mini Skirt',
        brand: 'H&M', size: 'M', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'new_with_tags', color: 'Pink',
        description: 'Adorable pleated skirt, never worn.',
        priceInCoins: 45,
        attributes: {'cut': 'Flare', 'rise': 'High', 'inseam': 'Short'},
        images: [img('skirt1'), extra(idx)], createdAt: DateTime(2025, 5, 20),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'Wide Leg Linen Pants',
        brand: 'Zara', size: 'M', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'like_new', color: 'Beige',
        description: 'Breezy linen wide legs, perfect for summer.',
        priceInCoins: 35,
        attributes: {'cut': 'Wide', 'rise': 'High', 'inseam': 'Long'},
        images: [img('linenpants'), extra(idx)], createdAt: DateTime(2025, 6, 1),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'Skinny Black Jeans',
        brand: "Levi's", size: 'M', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'good', color: 'Black',
        description: 'Classic 510 skinny fit in jet black.',
        priceInCoins: 30,
        attributes: {'cut': 'Skinny', 'rise': 'Mid', 'inseam': 'Regular'},
        images: [img('skinnyjeans2'), extra(idx)], createdAt: DateTime(2025, 7, 18),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-6', title: 'Bootcut Corduroy',
        brand: 'Wrangler', size: 'L', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'fair', color: 'Brown',
        description: 'Retro corduroy bootcut, minor fading.',
        priceInCoins: 25,
        attributes: {'cut': 'Bootcut', 'rise': 'Mid', 'inseam': 'Long'},
        images: [img('corduroy'), extra(idx)], createdAt: DateTime(2025, 8, 5),
      ),

      // ──── DRESSES (4) ────
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'Floral Midi Wrap Dress',
        brand: 'Zara', size: 'S', clothingType: ClothingType.dress,
        categoryId: 3, condition: 'good', color: 'Multi',
        description: 'Beautiful floral wrap dress, midi length.',
        priceInCoins: 55,
        attributes: {'length': 'Midi', 'sleeve': 'Short', 'style': 'Wrap'},
        images: [img('floraldress'), extra(idx)], createdAt: DateTime(2025, 3, 10),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'Black Cocktail Dress',
        brand: 'Massimo Dutti', size: 'S', clothingType: ClothingType.dress,
        categoryId: 3, condition: 'like_new', color: 'Black',
        description: 'Sleek cocktail dress, worn once.',
        priceInCoins: 65,
        attributes: {'length': 'Mini', 'sleeve': 'Sleeveless', 'style': 'Cocktail'},
        images: [img('cocktaildress'), extra(idx)], createdAt: DateTime(2025, 1, 30),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'Boho Maxi Dress',
        brand: 'Free People', size: 'M', clothingType: ClothingType.dress,
        categoryId: 3, condition: 'good', color: 'Terracotta',
        description: 'Flowy bohemian maxi with beautiful details.',
        priceInCoins: 70,
        attributes: {'length': 'Maxi', 'sleeve': 'Long', 'style': 'Boho'},
        images: [img('bohodress'), extra(idx)], createdAt: DateTime(2025, 4, 25),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'Casual Shirt Dress',
        brand: 'GAP', size: 'M', clothingType: ClothingType.dress,
        categoryId: 3, condition: 'good', color: 'Denim Blue',
        description: 'Easy-going denim shirt dress for everyday.',
        priceInCoins: 40,
        attributes: {'length': 'Midi', 'sleeve': 'Short', 'style': 'Shirt'},
        images: [img('shirtdress'), extra(idx)], createdAt: DateTime(2025, 5, 15),
      ),

      // ──── OUTERWEAR (5) ────
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'Vintage Denim Jacket',
        brand: "Levi's", size: 'M', clothingType: ClothingType.outerwear,
        categoryId: 4, condition: 'like_new', color: 'Blue',
        description: 'Classic trucker jacket with beautiful patina.',
        priceInCoins: 65,
        attributes: {'style': 'Jacket', 'fill_weight': 'Light'},
        images: [img('denimjacket'), extra(idx)], createdAt: DateTime(2025, 2, 5),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'Camel Wool Coat',
        brand: 'Max Mara', size: 'S', clothingType: ClothingType.outerwear,
        categoryId: 4, condition: 'like_new', color: 'Camel',
        description: 'Investment piece, timeless camel coat.',
        priceInCoins: 90,
        attributes: {'style': 'Coat', 'fill_weight': 'Heavy'},
        images: [img('woolcoat'), extra(idx)], createdAt: DateTime(2025, 1, 10),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-6', title: 'Puffer Vest',
        brand: 'The North Face', size: 'L', clothingType: ClothingType.outerwear,
        categoryId: 4, condition: 'like_new', color: 'Black',
        description: 'Lightweight 700-fill puffer vest.',
        priceInCoins: 55,
        attributes: {'style': 'Vest', 'fill_weight': 'Medium'},
        images: [img('puffervest'), extra(idx)], createdAt: DateTime(2025, 3, 22),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'Bomber Jacket',
        brand: 'Alpha Industries', size: 'M', clothingType: ClothingType.outerwear,
        categoryId: 4, condition: 'good', color: 'Olive',
        description: 'MA-1 bomber, iconic streetwear silhouette.',
        priceInCoins: 60,
        attributes: {'style': 'Bomber', 'fill_weight': 'Medium'},
        images: [img('bomber'), extra(idx)], createdAt: DateTime(2025, 6, 18),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-5', title: 'Cropped Blazer',
        brand: 'Mango', size: 'S', clothingType: ClothingType.outerwear,
        categoryId: 4, condition: 'new_with_tags', color: 'Black',
        description: 'Structured cropped blazer, brand new.',
        priceInCoins: 50,
        attributes: {'style': 'Blazer', 'fill_weight': 'Light'},
        images: [img('blazer'), extra(idx)], createdAt: DateTime(2025, 7, 8),
      ),

      // ──── SHOES (5) ────
      ClothingItem(
        id: id(), ownerId: 'user-2', title: 'White Leather Sneakers',
        brand: 'Nike', size: null, clothingType: ClothingType.shoes,
        categoryId: 5, condition: 'like_new', color: 'White',
        description: 'Air Force 1 lows, barely worn.',
        priceInCoins: 55,
        attributes: {'shoe_size': '40', 'style': 'Sneakers'},
        images: [img('af1'), extra(idx)], createdAt: DateTime(2025, 4, 2),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-5', title: 'Platform Combat Boots',
        brand: 'Dr. Martens', size: null, clothingType: ClothingType.shoes,
        categoryId: 5, condition: 'good', color: 'Black',
        description: 'Jadon platform boots, fully broken in.',
        priceInCoins: 65,
        attributes: {'shoe_size': '38', 'style': 'Boots'},
        images: [img('drmartens'), extra(idx)], createdAt: DateTime(2025, 5, 28),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-6', title: 'Running Shoes',
        brand: 'Adidas', size: null, clothingType: ClothingType.shoes,
        categoryId: 5, condition: 'good', color: 'Blue/White',
        description: 'Ultraboost 22, great for daily runs.',
        priceInCoins: 45,
        attributes: {'shoe_size': '43', 'style': 'Running'},
        images: [img('ultraboost'), extra(idx)], createdAt: DateTime(2025, 6, 30),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'Leather Loafers',
        brand: 'Massimo Dutti', size: null, clothingType: ClothingType.shoes,
        categoryId: 5, condition: 'like_new', color: 'Tan',
        description: 'Premium leather loafers, very comfortable.',
        priceInCoins: 50,
        attributes: {'shoe_size': '37', 'style': 'Loafers'},
        images: [img('loafers'), extra(idx)], createdAt: DateTime(2025, 2, 14),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'High-Top Sneakers',
        brand: 'Converse', size: null, clothingType: ClothingType.shoes,
        categoryId: 5, condition: 'good', color: 'Black',
        description: 'Chuck Taylor All Stars, classic high-tops.',
        priceInCoins: 35,
        attributes: {'shoe_size': '42', 'style': 'Sneakers'},
        images: [img('chucks'), extra(idx)], createdAt: DateTime(2025, 8, 1),
      ),

      // ──── ACCESSORIES (4) ────
      ClothingItem(
        id: id(), ownerId: 'user-3', title: 'New Era Baseball Cap',
        brand: 'New Era', size: null, clothingType: ClothingType.accessory,
        categoryId: 6, condition: 'new_with_tags', color: 'Navy',
        description: '59FIFTY fitted cap, brand new with tags.',
        priceInCoins: 20,
        attributes: {'style': 'Hat'},
        images: [img('cap1'), extra(idx)], createdAt: DateTime(2025, 3, 28),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-4', title: 'Leather Belt',
        brand: 'Coach', size: null, clothingType: ClothingType.accessory,
        categoryId: 6, condition: 'like_new', color: 'Brown',
        description: 'Genuine leather belt, reversible design.',
        priceInCoins: 25,
        attributes: {'style': 'Belt'},
        images: [img('belt1'), extra(idx)], createdAt: DateTime(2025, 4, 18),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-5', title: 'Mini Backpack',
        brand: 'Fjallraven', size: null, clothingType: ClothingType.accessory,
        categoryId: 6, condition: 'like_new', color: 'Yellow',
        description: 'Kanken mini, perfect daypack.',
        priceInCoins: 25,
        attributes: {'style': 'Backpack'},
        images: [img('kanken'), extra(idx)], createdAt: DateTime(2025, 5, 5),
      ),
      ClothingItem(
        id: id(), ownerId: 'user-6', title: 'Retro Sunglasses',
        brand: 'Ray-Ban', size: null, clothingType: ClothingType.accessory,
        categoryId: 6, condition: 'good', color: 'Tortoise',
        description: 'Wayfarer classic, timeless look.',
        priceInCoins: 20,
        attributes: {'style': 'Sunglasses'},
        images: [img('wayfarers'), extra(idx)], createdAt: DateTime(2025, 7, 22),
      ),

      // ──── USER-ME ITEMS (3) ────
      ClothingItem(
        id: id(), ownerId: _currentUserId, title: 'Striped Breton Tee',
        brand: 'Muji', size: 'M', clothingType: ClothingType.top,
        categoryId: 1, condition: 'good', color: 'Navy/White',
        description: 'Classic Breton stripe tee, soft organic cotton.',
        priceInCoins: 30,
        isActive: false, // sold
        attributes: {'sleeve': 'Short', 'collar': 'Crew', 'fit': 'Regular'},
        images: [img('stripetee'), extra(idx)], createdAt: DateTime(2025, 2, 1),
      ),
      ClothingItem(
        id: id(), ownerId: _currentUserId, title: 'Black Skinny Jeans',
        brand: "Levi's", size: 'M', clothingType: ClothingType.bottom,
        categoryId: 2, condition: 'good', color: 'Black',
        description: 'Well-loved 511 skinnies in faded black.',
        priceInCoins: 35,
        attributes: {'cut': 'Skinny', 'rise': 'Mid', 'inseam': 'Regular'},
        images: [img('skinnyjeans'), extra(idx)], createdAt: DateTime(2025, 3, 1),
      ),
      ClothingItem(
        id: id(), ownerId: _currentUserId, title: 'Canvas Tote Bag',
        brand: 'Baggu', size: null, clothingType: ClothingType.accessory,
        categoryId: 6, condition: 'like_new', color: 'Natural',
        description: 'Sturdy duck canvas tote, everyday carry.',
        priceInCoins: 15,
        attributes: {'style': 'Bag'},
        images: [img('tote1'), extra(idx)], createdAt: DateTime(2025, 4, 1),
      ),
    ];
  }

  // Pre-built orders
  static final List<Order> orders = [
    Order(
      id: 'order-1',
      buyerId: _currentUserId,
      sellerId: 'user-2',
      itemId: 'item-1',
      priceInCoins: 35,
      status: OrderStatus.completed,
      createdAt: DateTime(2026, 3, 10),
    ),
    Order(
      id: 'order-2',
      buyerId: 'user-4',
      sellerId: _currentUserId,
      itemId: 'item-34',
      priceInCoins: 30,
      status: OrderStatus.completed,
      createdAt: DateTime(2026, 3, 15),
    ),
    Order(
      id: 'order-3',
      buyerId: _currentUserId,
      sellerId: 'user-5',
      itemId: 'item-12',
      priceInCoins: 45,
      status: OrderStatus.confirmed,
      createdAt: DateTime(2026, 3, 20),
    ),
  ];

  static final List<Message> messages = [
    // order-1 messages
    Message(
      id: 'msg-1',
      orderId: 'order-1',
      senderId: 'user-2',
      content: 'Hey! Thanks for buying the band tee, you\'ll love it!',
      createdAt: DateTime(2026, 3, 10, 14, 30),
    ),
    Message(
      id: 'msg-2',
      orderId: 'order-1',
      senderId: _currentUserId,
      content: 'So excited! Where should we meet for the handoff?',
      createdAt: DateTime(2026, 3, 10, 14, 35),
    ),
    Message(
      id: 'msg-3',
      orderId: 'order-1',
      senderId: 'user-2',
      content: 'How about Dizengoff Center this Saturday?',
      createdAt: DateTime(2026, 3, 10, 14, 40),
    ),
    // order-2 messages
    Message(
      id: 'msg-4',
      orderId: 'order-2',
      senderId: 'user-4',
      content: 'Love the Breton tee! When can I pick it up?',
      createdAt: DateTime(2026, 3, 15, 10, 0),
    ),
    Message(
      id: 'msg-5',
      orderId: 'order-2',
      senderId: _currentUserId,
      content: 'Anytime this week works! I\'m in Tel Aviv most days.',
      createdAt: DateTime(2026, 3, 15, 10, 15),
    ),
    // order-3 messages
    Message(
      id: 'msg-6',
      orderId: 'order-3',
      senderId: _currentUserId,
      content: 'Hi! Just bought the pleated skirt, it\'s gorgeous!',
      createdAt: DateTime(2026, 3, 20, 16, 0),
    ),
    Message(
      id: 'msg-7',
      orderId: 'order-3',
      senderId: 'user-5',
      content: 'Thank you! Want to meet in Ramat Gan to pick it up?',
      createdAt: DateTime(2026, 3, 20, 16, 10),
    ),
  ];

  static final List<Transaction> transactions = [
    Transaction(
      id: 'tx-1',
      userId: _currentUserId,
      type: TransactionType.welcomeBonus,
      amount: 50,
      description: 'Welcome bonus',
      balanceAfter: 50,
      createdAt: DateTime(2025, 1, 15),
    ),
    Transaction(
      id: 'tx-2',
      userId: _currentUserId,
      type: TransactionType.purchase,
      amount: -35,
      description: 'Bought Vintage Band Tee',
      balanceAfter: 15,
      createdAt: DateTime(2026, 3, 10),
    ),
    Transaction(
      id: 'tx-3',
      userId: _currentUserId,
      type: TransactionType.sale,
      amount: 30,
      description: 'Sold Striped Breton Tee',
      balanceAfter: 45,
      createdAt: DateTime(2026, 3, 15),
    ),
    Transaction(
      id: 'tx-4',
      userId: _currentUserId,
      type: TransactionType.topup,
      amount: 50,
      description: 'Purchased 50 Style Coins',
      balanceAfter: 95,
      createdAt: DateTime(2026, 3, 18),
    ),
    Transaction(
      id: 'tx-5',
      userId: _currentUserId,
      type: TransactionType.purchase,
      amount: -45,
      description: 'Bought Pleated Mini Skirt',
      balanceAfter: 50,
      createdAt: DateTime(2026, 3, 20),
    ),
  ];

  /// Get the current mock user.
  static User get currentUser => users.first;

  /// Get shop items (active items not owned by user).
  static List<ClothingItem> getShopItems(String currentUserId) {
    return items
        .where((item) =>
            item.ownerId != currentUserId &&
            item.isActive)
        .toList();
  }

  /// Get order details for a user.
  static List<OrderDetail> getOrderDetails(String currentUserId) {
    return orders.map((order) {
      final isBuyer = order.buyerId == currentUserId;
      final otherUserId = isBuyer ? order.sellerId : order.buyerId;
      final orderMessages = getMessagesForOrder(order.id);
      final unread = orderMessages
          .where((msg) => msg.senderId != currentUserId && msg.readAt == null)
          .length;

      return OrderDetail(
        order: order,
        otherUser: getUserById(otherUserId)!,
        item: getItemById(order.itemId)!,
        lastMessage: orderMessages.isNotEmpty ? orderMessages.last : null,
        unreadCount: unread,
        isBuyer: isBuyer,
      );
    }).toList();
  }

  /// Get messages for an order.
  static List<Message> getMessagesForOrder(String orderId) {
    return messages
        .where((m) => m.orderId == orderId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Purchase an item: deduct buyer coins, credit seller, create order, mark item inactive.
  static Order? purchaseItem(String itemId, String buyerId) {
    final item = getItemById(itemId);
    if (item == null || !item.isActive) return null;

    final buyerIndex = users.indexWhere((u) => u.id == buyerId);
    final sellerIndex = users.indexWhere((u) => u.id == item.ownerId);
    if (buyerIndex == -1 || sellerIndex == -1) return null;

    final buyer = users[buyerIndex];
    if (buyer.styleCoinBalance < item.priceInCoins) return null;

    // Deduct buyer
    users[buyerIndex] = buyer.copyWith(
      styleCoinBalance: buyer.styleCoinBalance - item.priceInCoins,
    );

    // Credit seller
    final seller = users[sellerIndex];
    users[sellerIndex] = seller.copyWith(
      styleCoinBalance: seller.styleCoinBalance + item.priceInCoins,
    );

    // Mark item inactive
    final itemIndex = items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      items[itemIndex] = items[itemIndex].copyWith(isActive: false);
    }

    // Create order
    final order = Order(
      id: 'order-${orders.length + 1}',
      buyerId: buyerId,
      sellerId: item.ownerId,
      itemId: itemId,
      priceInCoins: item.priceInCoins,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
    );
    orders.add(order);

    // Create transactions
    transactions.add(Transaction(
      id: 'tx-${transactions.length + 1}',
      userId: buyerId,
      type: TransactionType.purchase,
      amount: -item.priceInCoins,
      description: 'Bought ${item.title}',
      balanceAfter: users[buyerIndex].styleCoinBalance,
      createdAt: DateTime.now(),
    ));
    transactions.add(Transaction(
      id: 'tx-${transactions.length + 1}',
      userId: item.ownerId,
      type: TransactionType.sale,
      amount: item.priceInCoins,
      description: 'Sold ${item.title}',
      balanceAfter: users[sellerIndex].styleCoinBalance,
      createdAt: DateTime.now(),
    ));

    return order;
  }

  /// Top up coins for a user.
  static void topUp(String userId, int amount) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final user = users[index];
    users[index] = user.copyWith(
      styleCoinBalance: user.styleCoinBalance + amount,
    );

    transactions.add(Transaction(
      id: 'tx-${transactions.length + 1}',
      userId: userId,
      type: TransactionType.topup,
      amount: amount,
      description: 'Purchased $amount Style Coins',
      balanceAfter: users[index].styleCoinBalance,
      createdAt: DateTime.now(),
    ));
  }

  /// Get transactions for a user.
  static List<Transaction> getTransactionsForUser(String userId) {
    return transactions
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get user by id.
  static User? getUserById(String id) {
    return users.where((u) => u.id == id).firstOrNull;
  }

  /// Get item by id.
  static ClothingItem? getItemById(String id) {
    return items.where((i) => i.id == id).firstOrNull;
  }

  /// Get items owned by a user.
  static List<ClothingItem> getItemsByOwner(String ownerId) {
    return items.where((i) => i.ownerId == ownerId && i.isActive).toList();
  }

  /// Get category by id.
  static Category? getCategoryById(int id) {
    return categories.where((c) => c.id == id).firstOrNull;
  }
}
