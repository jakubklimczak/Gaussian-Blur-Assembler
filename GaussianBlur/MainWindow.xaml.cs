using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace GaussianBlur
{


    public struct Pixel
    {
        public byte r;
        public byte g;
        public byte b;
        public byte a;
        public Pixel(byte _r, byte _g, byte _b, byte _a)
        {
            r = _r;
            g = _g;
            b = _b;
            a = _a;
        }
    }
    public unsafe class AsmProxy
    {
        [DllImport("GaussianBlurAsm.dll")]

        private static extern void Gauss(int arraysize, byte* arg1, byte* arg2, byte* arg3, byte* arg4, byte* arg5, byte* arg6);
        public void executeGauss(int arraysize, byte* arg1,byte* arg2,byte* arg3,byte* arg4,byte* arg5,byte* arg6) {
            
            Gauss(arraysize, arg1, arg2, arg3, arg4, arg5, arg6);
            //return 1.0;
        }
    }
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFile = new OpenFileDialog();
            if (openFile.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                Uri fileUri = new Uri(openFile.FileName);
                PictureBox1.Source = new System.Windows.Media.Imaging.BitmapImage(fileUri);

            }
        }

        private void Button_execute(object sender, RoutedEventArgs e)
        {
            BitmapImage mybitmapImage = (BitmapImage)(PictureBox1.Source);
            System.Drawing.Bitmap bitMapCopy = BitmapImage2Bitmap(mybitmapImage);
            int width = bitMapCopy.Width;
            int height = bitMapCopy.Height;
            Pixel[] inBMP = new Pixel[width * height];
            Pixel[] outBMP = new Pixel[width * height];

            for (int i = 0; i < width * height; i++) inBMP[i] = new Pixel();
            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                {
                    System.Drawing.Color bmpColor = bitMapCopy.GetPixel(x, y);

                    inBMP[y * width + x] = new Pixel(bmpColor.R, bmpColor.G, bmpColor.B, bmpColor.A);

                }

            unsafe
            {
                

                byte[] in_red = new byte[inBMP.Length];
                byte[] in_green = new byte[inBMP.Length];
                byte[] in_blue = new byte[inBMP.Length];
                for (int i = 0; i < inBMP.Length; i++)
                {
                    in_red[i] = inBMP[i].r;
                    in_green[i] = inBMP[i].g;
                    in_blue[i] = inBMP[i].b;
                }

                byte[] out_red = new byte[inBMP.Length];
                byte[] out_green = new byte[inBMP.Length];
                byte[] out_blue = new byte[inBMP.Length];

                AsmProxy asmP = new AsmProxy();
                fixed (byte* in_redAddr = in_red, in_greenAddr = in_green, in_blueAddr = in_blue,
                    out_redAddr = out_red, out_greenAddr = out_green, out_blueAddr = out_blue)
                {
                    asmP.executeGauss(width*height, in_redAddr, in_greenAddr, in_blueAddr,
                    out_redAddr, out_greenAddr, out_blueAddr );
                }

                
            }

            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                {
                    bitMapCopy.SetPixel(x, y, System.Drawing.Color.FromArgb((int)outBMP[y * width + x].r, (int)outBMP[y * width + x].g, (int)outBMP[y * width + x].b));

                }
            PictureBox2.Source = ToBitmapImage(bitMapCopy);

        }

        public bool ProccesImage(Bitmap bmp)
        {

            
            for (int i = 0; i < bmp.Width; i++)
            {
                for (int j = 0; j < bmp.Height; j++)
                {
                    System.Drawing.Color bmpColor = bmp.GetPixel(i, j);
                    float red = bmpColor.R;
                    float green = bmpColor.G;
                    float blue = bmpColor.B;
                    int gray = (int)(0.299 * red + .587 * green + .114 * blue);
                    bmp.SetPixel(i, j, System.Drawing.Color.FromArgb(gray, gray, gray));
                }
            }

            return true;
        }
        private Bitmap BitmapImage2Bitmap(BitmapImage bitmapImage)
        {
            // BitmapImage bitmapImage = new BitmapImage(new Uri("../Images/test.png", UriKind.Relative));

            using (System.IO.MemoryStream outStream = new System.IO.MemoryStream())
            {
                BitmapEncoder enc = new BmpBitmapEncoder();
                enc.Frames.Add(BitmapFrame.Create(bitmapImage));
                enc.Save(outStream);
                Bitmap bitmap = new Bitmap(outStream);

                return new Bitmap(bitmap);
            }
        }

        public BitmapImage ToBitmapImage(Bitmap bitmap)
        {
            using (var memory = new MemoryStream())
            {
                bitmap.Save(memory, ImageFormat.Png);
                memory.Position = 0;

                var bitmapImage = new BitmapImage();
                bitmapImage.BeginInit();
                bitmapImage.StreamSource = memory;
                bitmapImage.CacheOption = BitmapCacheOption.OnLoad;
                bitmapImage.EndInit();
                bitmapImage.Freeze();

                return bitmapImage;
            }
        }

    }
}
