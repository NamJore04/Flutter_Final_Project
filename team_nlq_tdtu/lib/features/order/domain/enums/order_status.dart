enum OrderStatus {
  pending,       // Đang chờ xử lý
  processing,    // Đang xử lý
  shipped,       // Đã giao cho đơn vị vận chuyển
  delivered,     // Đã giao hàng
  completed,     // Hoàn thành
  cancelled,     // Đã hủy
  refunded,      // Đã hoàn tiền
  returned       // Đã trả hàng
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xử lý';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.refunded:
        return 'Đã hoàn tiền';
      case OrderStatus.returned:
        return 'Đã trả hàng';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Đơn hàng của bạn đang chờ xác nhận';
      case OrderStatus.processing:
        return 'Đơn hàng của bạn đang được chuẩn bị';
      case OrderStatus.shipped:
        return 'Đơn hàng của bạn đang được vận chuyển';
      case OrderStatus.delivered:
        return 'Đơn hàng của bạn đã được giao thành công';
      case OrderStatus.completed:
        return 'Đơn hàng đã hoàn thành';
      case OrderStatus.cancelled:
        return 'Đơn hàng đã bị hủy';
      case OrderStatus.refunded:
        return 'Bạn đã được hoàn tiền cho đơn hàng này';
      case OrderStatus.returned:
        return 'Đơn hàng đã được trả lại';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return 'assets/icons/pending.png';
      case OrderStatus.processing:
        return 'assets/icons/processing.png';
      case OrderStatus.shipped:
        return 'assets/icons/shipping.png';
      case OrderStatus.delivered:
        return 'assets/icons/delivered.png';
      case OrderStatus.completed:
        return 'assets/icons/completed.png';
      case OrderStatus.cancelled:
        return 'assets/icons/cancelled.png';
      case OrderStatus.refunded:
        return 'assets/icons/refunded.png';
      case OrderStatus.returned:
        return 'assets/icons/returned.png';
    }
  }

  bool get canCancel {
    return this == OrderStatus.pending || 
           this == OrderStatus.processing || 
           this == OrderStatus.shipped;
  }

  bool get canReturn {
    return this == OrderStatus.delivered || 
           this == OrderStatus.completed;
  }

  bool get isCompleted {
    return this == OrderStatus.completed;
  }

  bool get isCancelled {
    return this == OrderStatus.cancelled;
  }

  bool get isActive {
    return this != OrderStatus.cancelled && 
           this != OrderStatus.returned && 
           this != OrderStatus.refunded;
  }

  String get value {
    switch (this) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.processing: return 'processing';
      case OrderStatus.shipped: return 'shipped';
      case OrderStatus.delivered: return 'delivered';
      case OrderStatus.completed: return 'completed';
      case OrderStatus.cancelled: return 'cancelled';
      case OrderStatus.returned: return 'returned';
      case OrderStatus.refunded: return 'refunded';
    }
  }
  
  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'processing': return OrderStatus.processing;
      case 'shipped': return OrderStatus.shipped;
      case 'delivered': return OrderStatus.delivered;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      case 'returned': return OrderStatus.returned;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.pending;
    }
  }
} 