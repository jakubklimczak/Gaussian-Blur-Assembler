using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows;
using System.Windows.Media.Imaging;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Timers;
using System.Threading;

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

        private static extern void Gauss(int arraysize, int width, ushort* arg1, ushort* arg2, ushort* arg3, ushort* arg4, ushort* arg5, ushort* arg6);
        public void executeGauss(int arraysize,int width, ushort* arg1, ushort* arg2, ushort* arg3, ushort* arg4, ushort* arg5, ushort* arg6) {
            
            Gauss(arraysize, width, arg1, arg2, arg3, arg4, arg5, arg6);

        }

        [DllImport("GaussianBlurCpp.dll")]

        private static extern void ExecuteGaussianBlurCpp(int arraysize, int width, ushort* arg1, ushort* arg2, ushort* arg3, ushort* arg4, ushort* arg5, ushort* arg6);
        public void executeGaussCpp(int arraysize, int width, ushort* arg1, ushort* arg2, ushort* arg3, ushort* arg4, ushort* arg5, ushort* arg6)
        {

            ExecuteGaussianBlurCpp(arraysize, width, arg1, arg2, arg3, arg4, arg5, arg6);
        }
    }
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public static System.Timers.Timer timer;
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

            //===============================================================================================================

            // Calculate the new width and height of the thumbnail image
            int newWidth = width + 2;
            int newHeight = height + 2;

            // Create a thumbnail image
            Image thumbnailImage = bitMapCopy.GetThumbnailImage(newWidth, newHeight, null, IntPtr.Zero);

            System.Drawing.Bitmap bitMapCopy2 = new Bitmap(thumbnailImage);
            //bitMapCopy2.Save("image_with_border.jpg", ImageFormat.Jpeg);
            //===============================================================================================================

            //System.Drawing.Bitmap bitMapCopy2 = new Bitmap(width + 2, height + 2);
            Pixel[] inBMP = new Pixel[newWidth * newHeight];
            //Pixel[] outBMP = new Pixel[width * height];

            for (int y = 0; y < newHeight; y++)
                for (int x = 0; x < newWidth; x++)
                {
                    if (x != 0 && y != 0 /*&& x != width && y != height*/ && x != width + 1 && y != height + 1)
                        bitMapCopy2.SetPixel(x, y, bitMapCopy.GetPixel(x - 1, y - 1));

                }


            for (int i = 0; i < newWidth * newHeight; i++) inBMP[i] = new Pixel();
            for (int y = 0; y < newHeight; y++)
                for (int x = 0; x < newWidth; x++)
                {
                    System.Drawing.Color bmpColor = bitMapCopy2.GetPixel(x, y);

                    inBMP[y * newWidth + x] = new Pixel(bmpColor.R, bmpColor.G, bmpColor.B, bmpColor.A);

                }

            unsafe
            {

                int offset = 2 * width + 2 * height + 4;
                ushort[] in_red = new ushort[inBMP.Length + offset];
                ushort[] in_green = new ushort[inBMP.Length + offset];
                ushort[] in_blue = new ushort[inBMP.Length + offset];

                ushort[] out_red = new ushort[inBMP.Length];
                ushort[] out_green = new ushort[inBMP.Length];
                ushort[] out_blue = new ushort[inBMP.Length];

                //for(int i = 0; i < in_red.Length; i++)
                //{
                //    if (i == 0)
                //    {
                //        in_red[i] = inBMP[0].r;
                //        in_green[i] = inBMP[0].g;
                //        in_blue[i] = inBMP[0].b;
                //    }
                //    else if (i == width + 1)
                //    {
                //        in_red[i] = inBMP[width - 1].r;
                //        in_green[i] = inBMP[width - 1].g;
                //        in_blue[i] = inBMP[width - 1].b;
                //    }
                //    else if (i == in_red.Length - width - 2)
                //    {
                //        in_red[i] = inBMP[width * height - width].r;
                //        in_green[i] = inBMP[width * height - width].g;
                //        in_blue[i] = inBMP[width * height - width].b;
                //    }
                //    else if (i == in_red.Length - 1)
                //    {
                //        in_red[i] = inBMP[width * height - 1].r;
                //        in_green[i] = inBMP[width * height - 1].g;
                //        in_blue[i] = inBMP[width * height - 1].b;
                //    }
                //    else if (i < width + 2)
                //    {
                //        //in_red[i] = inBMP[i].r;
                //        //in_green[i] = inBMP[i].g;
                //        //in_blue[i] = inBMP[i].b;
                //    }
                //}

                for (int i = 0; i < inBMP.Length; i++)
                {
                    in_red[i] = inBMP[i].r;
                    in_green[i] = inBMP[i].g;
                    in_blue[i] = inBMP[i].b;

                    //out_red[i] = inBMP[i].r;
                    //out_green[i] = inBMP[i].g;
                    //out_blue[i] = inBMP[i].b;

                    out_red[i] = (byte)255;
                    out_green[i] = (byte)255;
                    out_blue[i] = (byte)255;
                }



                AsmProxy asmP = new AsmProxy();
                fixed (ushort* in_redAddr = in_red, in_greenAddr = in_green, in_blueAddr = in_blue,
                    out_redAddr = out_red, out_greenAddr = out_green, out_blueAddr = out_blue)
                {
                    long elapsedMsAsm = 0, elapsedMsCpp = 0;

                    var watch = System.Diagnostics.Stopwatch.StartNew();

                    //asmP.executeGaussCpp(width * height, newWidth, in_redAddr, in_greenAddr, in_blueAddr,
                    //                    out_redAddr, out_greenAddr, out_blueAddr);
                    watch.Stop();
                    elapsedMsCpp = watch.ElapsedMilliseconds;

                    watch = System.Diagnostics.Stopwatch.StartNew();

                    asmP.executeGauss(width * height, newWidth, in_redAddr, in_greenAddr, in_blueAddr,
                    out_redAddr, out_greenAddr, out_blueAddr);

                    watch.Stop();
                    elapsedMsAsm = watch.ElapsedMilliseconds;


                    textoutput.Text = "Assembler: "+elapsedMsAsm.ToString()+"\nCpp: "+elapsedMsCpp.ToString();
                }

                for (int y = 0; y < height; y++)
                    for (int x = 0; x < width; x++)
                    {
                        bitMapCopy.SetPixel(x, y, System.Drawing.Color.FromArgb(out_red[x + width * y], out_green[x + width * y], out_blue[x + width * y]));
                    }

                //for (int y = 0; y < newHeight; y++)
                //    for (int x = 0; x < newWidth; x++)
                //    {
                //        bitMapCopy2.SetPixel(x, y, System.Drawing.Color.FromArgb(in_red[x + newWidth * y], in_green[x + newWidth * y], in_blue[x + newWidth * y]));
                //    }

                PictureBox2.Source = ToBitmapImage(bitMapCopy);
                bitMapCopy.Save("bitMapCopy.jpg", ImageFormat.Jpeg);
                bitMapCopy2.Save("bitMapCopy2.jpg", ImageFormat.Jpeg);

            }

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
