ffmpeg -f image2 -thread_queue_size 1024 -r 50 -i "output/%12d.bmp" -vcodec libx264 -start_number 1 -vframes 15950 -vf vflip,format=yuv420p  -b:v 2M -preset faster -y ../8.mp4
