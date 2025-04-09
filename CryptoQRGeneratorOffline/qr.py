# Скрипт для локальной генерации QR для ваших криптокошельков (например, для страницы приёма донатов: https://z15.neocities.org/donate)
# В центре QR будет расположен логотип, который уже заранее расположен в папке icons.
# Свои данные подставлять в addresses (строка 78)
# Online-версия скрипта (скорее всего устарел в связи с внедрением Cloudflare): https://github.com/Zalexanninev15/Scripts-and-snippets/blob/main/CryptoQRGenerator.py

import qrcode
from PIL import Image
import os

class CryptoQRGenerator:
    def __init__(self, output_dir="crypto_qr_codes", logo_dir="icons"):
        self.output_dir = output_dir
        self.logo_dir = logo_dir
        
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

    def _load_logo(self, crypto_type):
        logo_path = os.path.join(self.logo_dir, f"{crypto_type.lower()}.png")
        
        if not os.path.exists(logo_path):
            print(f"Логотип для {crypto_type} не найден. Использую плейсхолдер вместо логотипа.")
            placeholder = Image.new('RGBA', (100, 100), (255, 255, 255, 0))
            return placeholder
        
        try:
            logo = Image.open(logo_path)
            if logo.mode != 'RGBA':
                logo = logo.convert('RGBA')
            return logo
        except Exception as e:
            print(f"Ошибка при загрузке логотипа для {crypto_type}: {e}")
            placeholder = Image.new('RGBA', (100, 100), (255, 255, 255, 0))
            return placeholder

    def generate_qr(self, crypto_address, crypto_type, filename=None):
        crypto_type = crypto_type.lower()
        
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=10,
            border=4,
        )
        
        qr.add_data(crypto_address)
        qr.make(fit=True)
        
        qr_img = qr.make_image(fill_color="black", back_color="white").convert('RGBA')
        
        logo = self._load_logo(crypto_type)
        
        if logo:
            logo_size = qr_img.size[0] // 5
            logo = logo.resize((logo_size, logo_size), Image.LANCZOS)
            
            pos = ((qr_img.size[0] - logo.size[0]) // 2, (qr_img.size[1] - logo.size[1]) // 2)
            
            white_square = Image.new('RGBA', (logo_size + 8, logo_size + 8), (255, 255, 255, 255))
            qr_img.paste(white_square, (pos[0] - 4, pos[1] - 4), white_square)
            qr_img.paste(logo, pos, logo)
        
        qr_img = qr_img.resize((800, 800), Image.LANCZOS)
        
        if not filename:
            filename = f"{crypto_type.upper()}.png"
        
        file_path = os.path.join(self.output_dir, f"{filename.split('.')[0].upper()}.png")
        
        qr_img = qr_img.convert("P", palette=Image.ADAPTIVE)
        qr_img.save(file_path, optimize=True, quality=95)
        
        return file_path

def main():
    generator = CryptoQRGenerator()
    
    addresses = {
		"xmr": "",
        "usdt": "", 
        "trx": "", 
        "btc": "",
        "dogs": "",
        "ton": "",
        "not": "",
        "sol": "",
        "eth": ""
    }
    
    for crypto, address in addresses.items():
        file_path = generator.generate_qr(address, crypto)
        print(f"Создан QR-код для {crypto.upper()}: {file_path}")

if __name__ == "__main__":
    main()
