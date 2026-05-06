import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điều khoản & Điều kiện',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Cập nhật lần cuối: 20/03/2026',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '1. Điều Khoản Sử Dụng',
            content: '''
Bằng việc sử dụng ứng dụng Secondhand, bạn đồng ý tuân thủ tất cả các điều khoản và điều kiện được nêu dưới đây. Nếu bạn không đồng ý với bất kỳ phần nào, vui lòng không sử dụng ứng dụng.

Ứng dụng được cung cấp "như hiện tại" mà không có bất kỳ bảo đảm nào. Chúng tôi không chịu trách nhiệm về bất kỳ tổn thất hoặc thiệt hại nào phát sinh từ việc sử dụng ứng dụng này.
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '2. Tài Khoản Người Dùng',
            content: '''
• Bạn chịu trách nhiệm duy trì tính bảo mật của tài khoản của bạn
• Bạn phải cung cấp thông tin chính xác và đầy đủ khi đăng ký
• Bạn không được phép chia sẻ tài khoản với người khác
• Bạn chịu trách nhiệm về tất cả hoạt động xảy ra dưới tài khoản của bạn
• Nếu bạn nghi ngờ truy cập trái phép, hãy thay đổi mật khẩu ngay lập tức
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '3. Quy Tắc Bán Hàng',
            content: '''
• Các sản phẩm phải tuân theo pháp luật hiện hành
• Bạn phải mô tả sản phẩm một cách trung thực và chính xác
• Không được quảng cáo sản phẩm bị cấm hoặc giả mạo
• Người bán chịu trách nhiệm bảo đảm chất lượng sản phẩm
• Tất cả sản phẩm phải được duyệt trước khi công khai
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '4. Quy Tắc Mua Hàng',
            content: '''
• Bạn phải tuân thủ các hướng dẫn thanh toán
• Cung cấp địa chỉ giao hàng chính xác
• Bạn có quyền từ chối giao dịch nếu sản phẩm không đúng mô tả
• Không được hủy giao dịch sau khi người bán đã xác nhận
• Chịu trách nhiệm bảo quản sản phẩm nhận được
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '5. Thanh Toán & Ví',
            content: '''
• Tất cả giao dịch thanh toán là cuối cùng và không thể hoàn lại ngoại trừ trong trường hợp bất khả kháng
• Ví là tài khoản tiền của bạn trên nền tảng - không phải tiền thực
• Bạn có thể nạp tiền vào ví bất cứ lúc nào
• Số dư ví có thể được sử dụng mua hàng hoặc rút về tài khoản ngân hàng
• Chúng tôi có quyền khóa ví nếu phát hiện hoạt động bất thường
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '6. Trách Nhiệm Pháp Lý',
            content: '''
• Chúng tôi không chịu trách nhiệm về tranh chấp giữa người mua và người bán
• Chúng tôi có quyền xóa hoặc khóa tài khoản vi phạm các quy tắc
• Chúng tôi không đảm bảo tính khả dụng liên tục của ứng dụng
• Bạn phải tuân thủ tất cả luật pháp địa phương khi sử dụng ứng dụng
• Chúng tôi có quyền thay đổi các điều khoản này bất cứ lúc nào
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '7. Bảo Mật & Quyền Riêng Tư',
            content: '''
• Chúng tôi có thể thu thập dữ liệu cá nhân để cải thiện dịch vụ
• Dữ liệu của bạn sẽ được mã hóa và bảo vệ
• Chúng tôi không bao giờ chia sẻ thông tin cá nhân với bên thứ ba
• Bạn có quyền yêu cầu truy cập, chỉnh sửa hoặc xóa dữ liệu của bạn
• Xem Chính sách Bảo mật để biết thêm chi tiết
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '8. Hành Vi Cấm Chỉ',
            content: '''
Người dùng không được:
• Sử dụng ứng dụng để gây phiền hà, quấy rối hoặc đe dọa người khác
• Đăng nội dung khiêu dâm, bạo lực hoặc thù ghét
• Cố gắng khai thác hoặc hack ứng dụng
• Gửi thư rác hoặc nội dung lừa đảo
• Bán hàng giả mạo hoặc bị cấm
• Vi phạm quyền sở hữu trí tuệ
            ''',
          ),
          const SizedBox(height: 16),

          _TermsSection(
            title: '9. Liên Hệ',
            content: '''
Nếu bạn có bất kỳ câu hỏi về các điều khoản này, vui lòng liên hệ:

Email: legal@secondhand.app
Điện thoại: +84 912 345 678
Địa chỉ: Tp. Hồ Chí Minh, Việt Nam

Thời gian phản hồi: 2-3 ngày làm việc
            ''',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          content.trim(),
          style: const TextStyle(height: 1.6, fontSize: 13),
        ),
      ],
    );
  }
}
