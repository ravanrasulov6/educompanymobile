import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedInstallment = 0; // 0 = Birdəfəlik, 1 = 3 Ay, 2 = 6 Ay, 3 = 12 Ay
  String _cardName = '';
  String _cardNumber = '';
  String _expiryDate = '';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF101922) : const Color(0xFFf6f7f8),
      appBar: AppBar(
        title: const Text('Ödəniş', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/student/profile');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Card Representation
                _buildVisualCard(),
                
                const SizedBox(height: 24),
                
                // Card Details Section
                const Text(
                  'Kart məlumatları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Kartın üzərindəki ad',
                  hint: 'Məs: ELNUR MƏMMƏDOV',
                  isDarkMode: isDarkMode,
                  onChanged: (val) => setState(() => _cardName = val),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Kart nömrəsi',
                  hint: '0000 0000 0000 0000',
                  icon: Icons.credit_card_rounded,
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  onChanged: (val) {
                    setState(() {
                      // Basic grouping for visualization, remove spaces first
                      String cleaned = val.replaceAll(' ', '');
                      String formatted = '';
                      for (int i = 0; i < cleaned.length; i++) {
                        if (i > 0 && i % 4 == 0) formatted += ' ';
                        formatted += cleaned[i];
                      }
                      _cardNumber = formatted;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Bitmə tarixi',
                        hint: 'AA / İİ',
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        onChanged: (val) {
                          setState(() {
                            String cleaned = val.replaceAll('/', '').replaceAll(' ', '');
                            if (cleaned.length > 2) {
                              cleaned = '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
                            }
                            _expiryDate = cleaned;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'CVV / CVC',
                        hint: '***',
                        icon: Icons.info_outline_rounded,
                        isPassword: true,
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Installment Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Taksit seçimi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'HİSSƏ-HİSSƏ ÖDƏ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInstallmentCard(
                        index: 0,
                        title: 'Birdəfəlik',
                        price: '149.00 ₼',
                        bankInfo: '',
                        isDarkMode: isDarkMode,
                      ),
                      _buildInstallmentCard(
                        index: 1,
                        title: '3 Ay',
                        price: '49.66 ₼',
                        bankInfo: 'Birbank',
                        bankColor: Colors.red,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInstallmentCard(
                        index: 2,
                        title: '6 Ay',
                        price: '24.83 ₼',
                        bankInfo: 'Tamkart',
                        bankColor: Colors.blue[600]!,
                        isDarkMode: isDarkMode,
                      ),
                      _buildInstallmentCard(
                        index: 3,
                        title: '12 Ay',
                        price: '12.41 ₼',
                        bankInfo: 'Bolkart',
                        bankColor: Colors.orange,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Promo Code
                const Text(
                  'Kampaniya kodu',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Kodu daxil edin',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tətbiq et',
                        style: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Payment Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kursun qiyməti', style: TextStyle(color: Colors.grey[500])),
                          const Text('189.00 ₼', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Güzəşt (Promo)', style: TextStyle(color: Colors.grey[500])),
                          const Text('- 40.00 ₼', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Yekun məbləğ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('149.00 ₼', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Security Trust
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'TƏHLÜKƏSİZ 256-BİT SSL ŞİFRƏLƏMƏ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Sticky Footer Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF101922).withOpacity(0.9) : const Color(0xFFf6f7f8).withOpacity(0.9),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Ödənişi tamamla — 149.00 ₼',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualCard() {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            const Color(0xFF1a5fb4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.contactless_rounded, color: Colors.white, size: 36),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KARTIN NÖMRƏSİ',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cardNumber.isEmpty ? '**** **** **** 4242' : _cardNumber,
                    style: TextStyle(color: Colors.white, fontSize: _cardNumber.isEmpty ? 24 : 22, letterSpacing: 3.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KART SAHİBİ',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _cardName.isEmpty ? 'AD SOYAD' : _cardName.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'BİTMƏ TARİXİ',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _expiryDate.isEmpty ? '08/28' : _expiryDate,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    IconData? icon,
    bool isPassword = false,
    required bool isDarkMode,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        TextField(
          obscureText: isPassword,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: '', // Hide the length counter below the field
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentCard({
    required int index,
    required String title,
    required String price,
    required String bankInfo,
    Color bankColor = Colors.grey,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedInstallment == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInstallment = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 110,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : (isDarkMode ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode && !isSelected ? Colors.white : (isSelected ? AppColors.primary : Colors.black),
              ),
            ),
            if (bankInfo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                bankInfo,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: bankColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
