# 📚 Ứng Dụng Quản Lý Tiểu Thuyết  

---

## 📖 Tổng Quan  
**Ứng dụng Quản Lý Tiểu Thuyết** là một ứng dụng di động đa nền tảng giúp người dùng **quản lý tiểu thuyết**, sắp xếp các chương và mang đến **trải nghiệm đọc mượt mà**. Ứng dụng hỗ trợ **xác thực người dùng**, **đồng bộ dữ liệu theo thời gian thực**, và giao diện đọc tối ưu, tạo ra trải nghiệm hấp dẫn cho cả người đọc và người viết.  

---

## 🔧 Công Nghệ Sử Dụng  
- **Frontend**: Flutter (Dart)  
- **Backend**: Firebase Authentication, Firestore (Cơ sở dữ liệu NoSQL)  
- **Quản lý trạng thái**: Provider  
- **Thư viện bổ trợ**:  
  - Cached Network Image (Lưu trữ hình ảnh)  
  - Shimmer (Hiệu ứng tải dữ liệu)  

---

## 🚀 Tính Năng Chính  
- **Xác Thực & Phân Quyền Người Dùng:** Đăng nhập và đăng ký an toàn bằng Firebase Authentication.  
- **Quản Lý Tiểu Thuyết & Chương:** Thêm, chỉnh sửa, xóa và sắp xếp tiểu thuyết cùng các chương.  
- **Tối Ưu Trải Nghiệm Đọc:** Cuộn mượt mà, chế độ tối, tùy chỉnh cỡ chữ và lưu vị trí đọc cuối cùng.  
- **Lưu Trữ Dữ Liệu Trên Đám Mây:** Đồng bộ hóa dữ liệu theo thời gian thực trên nhiều thiết bị bằng Firestore.  
- **Tối Ưu Giao Diện & Trải Nghiệm Người Dùng:** Hiệu ứng mượt mà, skeleton loading và thiết kế responsive.  
- **Xử Lý Hình Ảnh Hiệu Quả:** Lưu trữ ảnh được cache giúp tải nhanh hơn và trải nghiệm mượt mà hơn.  

---

## 📱 Hình Ảnh Giao Diện  
*Đang cập nhật...*  

---

## 🚀 Bắt Đầu Sử Dụng  
1. **Clone repository**:  
    ```bash
    git clone https://github.com/ten-cua-ban/novel-management-app.git
    ```

2. **Chuyển vào thư mục dự án**:  
    ```bash
    cd novel-management-app
    ```

3. **Cài đặt các dependencies**:  
    ```bash
    flutter pub get
    ```

4. **Chạy ứng dụng**:  
    ```bash
    flutter run
    ```

---

## 🔑 Cấu Hình Firebase  
1. Truy cập [Firebase Console](https://console.firebase.google.com/).  
2. Tạo dự án mới và bật **Authentication** cùng **Firestore Database**.  
3. Tải về `google-services.json` cho Android và `GoogleService-Info.plist` cho iOS.  
4. Đặt chúng vào các thư mục tương ứng:  
   - `android/app` cho `google-services.json`  
   - `ios/Runner` cho `GoogleService-Info.plist`  

---

## 🛠 Cấu Hình Khác  
- Cập nhật `firebase_options.dart` với cấu hình dự án Firebase của bạn.  
- Đảm bảo các dependencies tương thích bằng cách chạy:  
    ```bash
    flutter pub outdated
    flutter pub upgrade
    ```

---

## 📚 Các Gói Được Sử Dụng  
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_auth: latest_version
  cloud_firestore: latest_version
  provider: latest_version
  cached_network_image: latest_version
  shimmer: latest_version
