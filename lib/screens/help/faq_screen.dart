import 'package:flutter/material.dart';
import 'package:secondhand_app/config/theme.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: 'Làm cách nào để tạo tài khoản?',
      answer: 'Bạn có thể tạo tài khoản bằng cách nhấn nút "Đăng ký" trên màn hình đăng nhập. Cung cấp email, password và thông tin cá nhân của bạn. Sau đó xác nhận email của bạn để kích hoạt tài khoản.'
    ),
    FAQItem(
      question: 'Làm cách nào để đăng bán sản phẩm?',
      answer: 'Đi tới "Đăng bán sản phẩm" từ menu chính. Nhập tên, mô tả, giá sản phẩm, chọn ảnh rồi nhấn "Đăng bán". Sản phẩm sẽ đợi duyệt từ quản trị viên trước khi hiển thị công khai.'
    ),
    FAQItem(
      question: 'Làm cách nào để mua một sản phẩm?',
      answer: 'Tìm sản phẩm bạn muốn từ danh sách. Nhấn vào sản phẩm, review chi tiết rồi nhấn "Mua ngay". Chọn phương thức thanh toán và địa chỉ nhận hàng, sau đó xác nhận. Chờ người bán xác nhận và hoàn tất giao dịch.'
    ),
    FAQItem(
      question: 'Phương thức thanh toán nào được hỗ trợ?',
      answer: 'Chúng tôi hỗ trợ: Ví điện tử (Wallet), Chuyển khoản ngân hàng, Thẻ tín dụng/Ghi nợ, E-wallet khác (Momo, Zalo Pay, etc.). Bạn có thể nạp tiền vào ví để sử dụng bất cứ lúc nào.'
    ),
    FAQItem(
      question: 'Hàng được giao trong bao lâu?',
      answer: 'Thời gian giao hàng phụ thuộc vào địa chỉ nhận và người bán. Thường từ 2-7 ngày. Bạn có thể kiểm tra trạng thái giao dịch trong mục "Giao dịch" bất cứ lúc nào.'
    ),
    FAQItem(
      question: 'Làm cách nào để hoàn trả hàng?',
      answer: 'Nếu sản phẩm không đúng như mô tả, bạn có thể liên hệ với người bán trực tiếp hoặc gửi báo cáo cho chúng tôi. Chúng tôi sẽ xem xét và hỗ trợ quá trình hoàn trả theo chính sách của ứng dụng.'
    ),
    FAQItem(
      question: 'Ví của tôi là gì?',
      answer: 'Ví là tài khoản tiền của bạn trên ứng dụng. Bạn có thể nạp tiền vào ví, sử dụng để mua hàng, hoặc rút tiền về tài khoản ngân hàng. Ví giúp các giao dịch được nhanh chóng và an toàn hơn.'
    ),
    FAQItem(
      question: 'Tài khoản của tôi có an toàn không?',
      answer: 'Có, chúng tôi mã hóa tất cả dữ liệu cá nhân và thanh toán. Bạn nên giữ bí mật password và không chia sẻ OTP với ai. Nếu nghi ngờ bất kỳ hoạt động bất thường, hãy đổi password ngay lập tức.'
    ),
  ];

  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(
            faqs.length,
            (index) => _FAQTile(
              faq: faqs[index],
              isExpanded: expandedIndex == index,
              onTap: () {
                setState(() {
                  expandedIndex = expandedIndex == index ? null : index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class _FAQTile extends StatelessWidget {
  final FAQItem faq;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FAQTile({
    required this.faq,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        onExpansionChanged: (_) => onTap(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
