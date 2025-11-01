Giải thích :

File Control.v là file điều khiển tín hiệu của mấy thằng kia ( bram.v, compute.v , image_address.v )
File bram.v kiểu giống module lưu trữ ( thì ở đây t tạo 2 khối module riêng , một cái lưu trữ input, một cái lưu trữ output ).
File compute.v là file tính toán thuật toán
file image_address là file lấy địa chỉ, giống kiểu lấy input từ bram rồi đưa vào module compute tính toán này nọ rồi đưa vào thằng output.

Ở đây t chỉ dùng 1 thằng bram lưu trữ input của cả 3 thằng R, G, B luôn chứ không tách ra thành 3 khối module riêng nữa. ( tốc độ nó sẽ chậm hơn thay vì dùng 3 thằng riêng thôi, này từ từ trong quá trình làm rồi update lên 3 sau ).

Hiện tại thì t chỉ tính toán chuyển từ RGB sang Grayscale ( YCbCr thì làm hay không thì t chưa biết ).
