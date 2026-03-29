import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/order_model.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/order_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/cart/cart_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'United States');
  final _phoneController = TextEditingController();
  
  // Card details
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  
  bool _isProcessing = false;
  String? _errorMessage;

  // Validate card number using Luhn algorithm
  bool _isValidCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.isEmpty) return false;
    
    int sum = 0;
    bool isEven = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      isEven = !isEven;
    }
    
    return sum % 10 == 0;
  }

  // Validate expiry date (MM/YY format and not expired)
  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    
    // Check format MM/YY
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Use MM/YY';
    }
    
    final parts = value.split('/');
    final month = int.tryParse(parts[0]) ?? 0;
    final year = int.tryParse(parts[1]) ?? 0;
    
    // Check valid month (01-12)
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    
    // Check if card is expired
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card expired';
    }
    
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill with user data if available
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      _nameController.text = authState.user!.name;
      _phoneController.text = authState.user!.phone ?? '';
      _addressController.text = authState.user!.address ?? '';
      _cityController.text = authState.user!.city ?? '';
      _zipCodeController.text = authState.user!.zipCode ?? '';
      _countryController.text = authState.user!.country ?? 'United States';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final cartState = context.read<CartBloc>().state;
      final authState = context.read<AuthBloc>().state;
      
      if (authState.user == null) {
        throw Exception('Please log in to complete your purchase');
      }

      // Validate card details
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      if (cardNumber.length < 13 || cardNumber.length > 19) {
        throw Exception('Please enter a valid card number');
      }
      if (!_isValidCardNumber(cardNumber)) {
        throw Exception('Invalid card number');
      }

      // Validate expiry
      final expiryValidation = _validateExpiry(_expiryController.text);
      if (expiryValidation != null) {
        throw Exception(expiryValidation);
      }

      // Validate CVC
      final cvc = _cvcController.text;
      if (cvc.length < 3 || cvc.length > 4) {
        throw Exception('Invalid CVC');
      }

      // Create shipping address
      final shippingAddress = ShippingAddress(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        country: _countryController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Create order
      final order = await getIt<OrderRepository>().createOrder(
        user: authState.user!,
        cart: cartState.cart,
        shippingAddress: shippingAddress,
        paymentIntentId: 'pi_demo_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Clear cart
      if (mounted) {
        context.read<CartBloc>().add(CartCleared());
        
        // Navigate to confirmation
        context.go('/order-confirmation/${order.id}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address Section
                  Text(
                    'Shipping Address',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _zipCodeController,
                          decoration: const InputDecoration(
                            labelText: 'ZIP Code',
                            prefixIcon: Icon(Icons.pin_drop_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      prefixIcon: Icon(Icons.public_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your country';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (Optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment Method Section
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.credit_card, color: Color(0xFF635BFF)),
                              const SizedBox(width: 8),
                              const Text('Credit Card'),
                              const Spacer(),
                              const Icon(Icons.lock, size: 16, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Card Number with auto-formatting
                          TextFormField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _CardNumberInputFormatter(),
                            ],
                            maxLength: 19,
                            decoration: const InputDecoration(
                              labelText: 'Card Number',
                              hintText: '1234 5678 9012 3456',
                              prefixIcon: Icon(Icons.credit_card),
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter card number';
                              }
                              final cleanValue = value.replaceAll(' ', '');
                              if (cleanValue.length < 13 || cleanValue.length > 19) {
                                return 'Please enter a valid card number';
                              }
                              if (!_isValidCardNumber(cleanValue)) {
                                return 'Invalid card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    _ExpiryDateInputFormatter(),
                                  ],
                                  maxLength: 5,
                                  decoration: const InputDecoration(
                                    labelText: 'Expiry (MM/YY)',
                                    hintText: 'MM/YY',
                                    counterText: '',
                                  ),
                                  validator: _validateExpiry,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvcController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 4,
                                  decoration: const InputDecoration(
                                    labelText: 'CVC',
                                    hintText: '123',
                                    counterText: '',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3 || value.length > 4) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Test mode: Use card 4242 4242 4242 4242',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Order Summary
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('\$${cartState.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tax (10%)'),
                              Text('\$0.00'),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '\$${cartState.total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Pay Now'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Input formatter for card number (adds space every 4 digits)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all spaces
    String text = newValue.text.replaceAll(' ', '');
    
    // Limit to 16 digits
    if (text.length > 16) {
      text = text.substring(0, 16);
    }
    
    // Add spaces every 4 digits
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

// Input formatter for expiry date (adds slash after MM)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove slash
    String text = newValue.text.replaceAll('/', '');
    
    // Limit to 4 digits
    if (text.length > 4) {
      text = text.substring(0, 4);
    }
    
    // Add slash after 2 digits
    if (text.length >= 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
