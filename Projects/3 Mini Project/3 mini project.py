### First Project ---- YouTube video downloader

import os
from pytube import YouTube

def download_video():
    try:
        url = input("Enter the YouTube link: ")
        yt = YouTube(url)
        print("Title: ", yt.title)
        print("View: ", yt.views)
        stream = yt.streams.get_highest_resolution()
        stream.download() # mentioning path (download_path = stream.download(output_path=output_dir))
        print("Download completed.")
    except Exception as e:
        print("An error occured: ", str(e))

if __name__ == "__main__":
    download_video()

print("Current working directory:", os.getcwd()) # Print the current working directory


### Second Project ---- Video Downloader

import os
import subprocess

def download_video():
    try:
        url = input("Enter the video link: ")
        download_dir = input("Enter the directory where you want to save the video (leave blank for current directory): ")

        if not download_dir:
            download_dir = os.getcwd()
        
        # Ensure the download directory exists
        os.makedirs(download_dir, exist_ok=True)

        # Create a download command using yt-dlp
        command = f'yt-dlp -o "{download_dir}/%(title)s-%(id)s.%(ext)s" {url}'
        
        # Execute the command
        result = subprocess.run(command, shell=True, capture_output=True, text=True)

        # Print stdout and stderr
        print("stdout:", result.stdout)
        print("stderr:", result.stderr)
        
        if result.returncode == 0:
            print("Download completed successfully.")
        else:
            print("Download failed with errors.")
    
    except Exception as e:
        print("An error occurred:", str(e))

if __name__ == "__main__":
    download_video()

### Third Project --- Merging PDF file

import PyPDF2
import os

merger = PyPDF2.PdfMerger()

for file in os.listdir(os.curdir):
    if file.endswith(".pdf"):
        merger.append(file)
    merger.write("combined.pdf")





