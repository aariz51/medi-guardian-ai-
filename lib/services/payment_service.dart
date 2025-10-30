import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import '../models/subscription_tier.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs for different platforms
  static const String monthlyProductId = 'medi_guardian_monthly';
  static const String yearlyProductId = 'medi_guardian_yearly';
  
  // Android specific
  static const String monthlyProductIdAndroid = 'medi_guardian_monthly_android';
  static const String yearlyProductIdAndroid = 'medi_guardian_yearly_android';
  
  // iOS specific
  static const String monthlyProductIdIOS = 'medi_guardian_monthly_ios';
  static const String yearlyProductIdIOS = 'medi_guardian_yearly_ios';

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;

  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      throw Exception('In-app purchase not available');
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Purchase stream error: $error'),
    );

    // Load products
    await _loadProducts();
    
    // Restore previous purchases
    await _restorePurchases();
  }

  Future<void> _loadProducts() async {
    final Set<String> productIds = {
      if (Platform.isAndroid) ...[
        monthlyProductIdAndroid,
        yearlyProductIdAndroid,
      ] else if (Platform.isIOS) ...[
        monthlyProductIdIOS,
        yearlyProductIdIOS,
      ],
    };

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }
    
    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
  }

  Future<void> _restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Handle pending purchase
      print('Purchase pending: ${purchaseDetails.productID}');
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
               purchaseDetails.status == PurchaseStatus.restored) {
      // Handle successful purchase
      await _verifyPurchase(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      // Handle purchase error
      print('Purchase error: ${purchaseDetails.error}');
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      // Handle canceled purchase
      print('Purchase canceled: ${purchaseDetails.productID}');
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Here you would typically verify the purchase with your backend
    // For now, we'll just store it locally
    _purchases.add(purchaseDetails);
    
    // Update user's subscription status
    await _updateSubscriptionStatus(purchaseDetails);
  }

  Future<void> _updateSubscriptionStatus(PurchaseDetails purchaseDetails) async {
    // This would typically involve calling your backend API
    // to update the user's subscription status
    print('Updating subscription status for: ${purchaseDetails.productID}');
  }

  Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    try {
      String productId;
      
      if (Platform.isAndroid) {
        productId = tier == SubscriptionTier.monthly 
            ? monthlyProductIdAndroid 
            : yearlyProductIdAndroid;
      } else if (Platform.isIOS) {
        productId = tier == SubscriptionTier.monthly 
            ? monthlyProductIdIOS 
            : yearlyProductIdIOS;
      } else {
        throw Exception('Platform not supported');
      }

      final ProductDetails? product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      if (product == null) {
        throw Exception('Product not found');
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      if (tier == SubscriptionTier.monthly) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  Future<bool> startFreeTrial(SubscriptionTier tier) async {
    try {
      // For free trial, we would typically:
      // 1. Create a subscription with a trial period
      // 2. Set up automatic billing after trial ends
      // 3. Update user's trial status in backend
      
      print('Starting free trial for ${tier.name}');
      
      // This would be implemented based on your backend logic
      await _updateTrialStatus(tier);
      
      return true;
    } catch (e) {
      print('Free trial error: $e');
      return false;
    }
  }

  Future<void> _updateTrialStatus(SubscriptionTier tier) async {
    // Update trial status in your backend
    print('Updating trial status for: ${tier.name}');
  }

  bool hasActiveSubscription() {
    return _purchases.any((purchase) => 
        purchase.status == PurchaseStatus.purchased || 
        purchase.status == PurchaseStatus.restored);
  }

  SubscriptionTier? getCurrentSubscriptionTier() {
    if (!hasActiveSubscription()) {
      return SubscriptionTier.free;
    }

    // Check which subscription is active
    for (final purchase in _purchases) {
      if (purchase.status == PurchaseStatus.purchased || 
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID.contains('monthly')) {
          return SubscriptionTier.monthly;
        } else if (purchase.productID.contains('yearly')) {
          return SubscriptionTier.yearly;
        }
      }
    }

    return SubscriptionTier.free;
  }

  Future<void> cancelSubscription() async {
    try {
      // This would typically involve calling your backend
      // to cancel the subscription
      print('Canceling subscription');
    } catch (e) {
      print('Cancel subscription error: $e');
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
