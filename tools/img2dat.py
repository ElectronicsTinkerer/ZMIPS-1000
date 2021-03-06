
from PIL import Image
import sys


if __name__ == "__main__":
    argv = sys.argv

    if len(argv) < 2:
        print("Expected image file")
        print("img2dat file.img [--nomask]")
        exit(-1)

    with Image.open(argv[1]) as im:
        
        pixels = list(im.getdata())
        # print(pixels)
        # exit(0)
        datalist = []
        masklist = []

        for i in range(0, len(pixels)-1, 8):
            data:int = 0
            mask:int = 0
            for px in pixels[i:i+8]:
                data >>= 4 # Note the direction of shifting. This horizontally reverses the sprite data
                data |= (px & 0xf) << 28
                mask >>= 4
                if px != 16:
                    mask |= 0xf0000000
            datalist.append(data)
            masklist.append(mask)

        print(f"    ; Sprite data - {argv[1]}")
        for d in datalist:
            print(f"    .word 0x{d:08x}")

        if len(argv) > 2 and not argv[2] == "--nomask":
            print(f"    ; Sprite mask - {argv[1]}")
            for m in masklist:
                print(f"    .word 0x{m:08x}")

