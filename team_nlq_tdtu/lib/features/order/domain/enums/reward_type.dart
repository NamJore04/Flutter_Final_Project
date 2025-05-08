enum RewardType {
  purchase,       // Mua hàng
  review,         // Đánh giá sản phẩm
  referral,       // Giới thiệu người dùng mới
  promotion,      // Khuyến mãi
  birthday,       // Sinh nhật
  subscription,   // Đăng ký thành viên
  manual          // Cộng điểm thủ công
}

extension RewardTypeExtension on RewardType {
  String get displayName {
    switch (this) {
      case RewardType.purchase:
        return 'Mua hàng';
      case RewardType.review:
        return 'Đánh giá sản phẩm';
      case RewardType.referral:
        return 'Giới thiệu bạn bè';
      case RewardType.promotion:
        return 'Khuyến mãi';
      case RewardType.birthday:
        return 'Sinh nhật';
      case RewardType.subscription:
        return 'Đăng ký thành viên';
      case RewardType.manual:
        return 'Cộng điểm thưởng';
    }
  }

  String get description {
    switch (this) {
      case RewardType.purchase:
        return 'Điểm thưởng từ việc mua hàng';
      case RewardType.review:
        return 'Điểm thưởng từ việc đánh giá sản phẩm';
      case RewardType.referral:
        return 'Điểm thưởng từ việc giới thiệu bạn bè';
      case RewardType.promotion:
        return 'Điểm thưởng từ chương trình khuyến mãi';
      case RewardType.birthday:
        return 'Điểm thưởng sinh nhật';
      case RewardType.subscription:
        return 'Điểm thưởng từ việc đăng ký thành viên';
      case RewardType.manual:
        return 'Điểm thưởng được cộng thủ công';
    }
  }
} 