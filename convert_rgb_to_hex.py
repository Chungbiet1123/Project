# rgb_to_hex.py
# Chuyển ảnh RGB (220x220) → bram_rgb_init.hex (48,400 dòng, 6 ký tự hex/dòng)

from PIL import Image
import os

def rgb_to_bram_hex(input_image_path, output_hex_path, target_width=220, target_height=220):
    """
    Đọc ảnh RGB → resize → xuất file .hex đúng định dạng cho bram.v
    """
    print(f"Đang đọc ảnh: {input_image_path}")
    
    # 1. Mở và chuyển sang RGB
    try:
        img = Image.open(input_image_path).convert("RGB")
    except Exception as e:
        raise FileNotFoundError(f"Không mở được ảnh: {e}")

    # 2. Resize về 220x220 (nếu cần)
    if img.size != (target_width, target_height):
        print(f"Resize ảnh từ {img.size} → ({target_width}, {target_height})")
        img = img.resize((target_width, target_height), Image.Resampling.LANCZOS)

    # 3. Lấy dữ liệu pixel theo thứ tự: (R, G, B) từ trái-phải, trên-dưới
    pixels = list(img.getdata())  # List of tuples (R, G, B)
    total_pixels = len(pixels)
    expected_pixels = target_width * target_height

    if total_pixels != expected_pixels:
        raise ValueError(f"Số pixel không khớp: {total_pixels} ≠ {expected_pixels}")

    # 4. Ghi file .hex
    print(f"Đang ghi file .hex: {output_hex_path} ({total_pixels} pixel)")
    with open(output_hex_path, 'w') as f:
        for i, (r, g, b) in enumerate(pixels):
            hex_pixel = f"{r:02X}{g:02X}{b:02X}"
            f.write(hex_pixel + '\n')
            # In tiến trình (tùy chọn)
            if (i + 1) % 10000 == 0:
                print(f"   Đã xử lý: {i + 1}/{total_pixels} pixel")

    print(f"HOÀN TẤT!")
    print(f"   File: {output_hex_path}")
    print(f"   Kích thước: {target_width}x{target_height} = {total_pixels} pixel")
    print(f"   Tổng dòng: {total_pixels}")
    print(f"   Dùng trong Verilog: INIT_FILE(\"bram_rgb_init.hex\")")

# =============================================
# SỬ DỤNG (chạy trực tiếp)
# =============================================
if __name__ == "__main__":
    # Thay đổi 2 đường dẫn này
    INPUT_IMAGE  = "image/343535-Jet.png"          # Ảnh đầu vào (PNG, JPG, BMP...)
    OUTPUT_HEX   = "C:/Users/Lenovo/OneDrive/Documents/ an/Colorspace/data/bram_rgb_init.hex"  # File .hex đầu ra

    if not os.path.exists(INPUT_IMAGE):
        print(f"LỖI: Không tìm thấy file ảnh: {INPUT_IMAGE}")
        print("   Hãy đặt ảnh vào cùng thư mục và sửa tên ở dòng INPUT_IMAGE")
    else:
        rgb_to_bram_hex(INPUT_IMAGE, OUTPUT_HEX)