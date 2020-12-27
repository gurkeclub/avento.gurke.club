ffmpeg -f image2 -thread_queue_size 1024 -r 50 -i "output/%12d.bmp" -vcodec libx264 -start_number 1 -vframes 8200 -vf vflip,format=yuv420p  -b:v 2M -preset faster -y ../11.mp4
