#!/usr/bin/env python3
"""
extract_frames.py

Extract N evenly‐spaced frames from a video file (in the same folder as this script)
and save them into a new folder (created automatically) next to the video.

Usage (from the folder containing both this script and your video file):
    python extract_frames.py --video myvideo.mp4 --num_frames 10

Dependencies:
    pip install opencv-python

This script:
    1. Verifies the video file exists.
    2. Creates an output folder named "<video_name>_frames" (e.g. "myvideo_frames").
    3. Opens the video with OpenCV.
    4. Computes N evenly spaced frame indices across the video's length.
    5. Reads each of those frames and saves them as "<video_name>_frame_000001.jpg", etc.
"""

import os
import sys
import argparse
import cv2


def extract_evenly_spaced_frames(video_path, output_dir, num_frames):
    """
    Opens video_path, samples num_frames indices evenly across its length,
    and writes those frames to output_dir as JPEGs. Filenames will include
    the base name of the video.
    """
    # Determine base name (without extension) of the video for filename prefix
    base_name = os.path.splitext(os.path.basename(video_path))[0]

    # Open the video
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise IOError(f"Cannot open video file: {video_path}")

    # Get total frame count
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total_frames <= 0:
        raise ValueError("Unable to retrieve frame count or video is empty.")

    # Compute N evenly spaced frame indices (0-based)
    if num_frames > total_frames:
        print(f"Requested {num_frames} frames, but video only has {total_frames} frames.")
        print(f"Reducing to {total_frames} frames.")
        num_frames = total_frames

    if num_frames == 1:
        indices = [0]
    else:
        indices = [
            int(round(i * ((total_frames - 1) / (num_frames - 1))))
            for i in range(num_frames)
        ]

    print(f"Video has {total_frames} frames. Extracting frames at indices: {indices}")

    # Read and save each selected frame
    for count, frame_idx in enumerate(indices, start=1):
        # Seek to the desired frame
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
        ret, frame = cap.read()
        if not ret:
            print(f"Warning: could not read frame {frame_idx}. Skipping.")
            continue

        # Build output filename: "<video_name>_frame_000001.jpg"
        filename = f"{base_name}_frame_{count:06d}.jpg"
        out_filename = os.path.join(output_dir, filename)
        cv2.imwrite(out_filename, frame)
        print(f"Saved frame {frame_idx} as {out_filename}")

    cap.release()
    print("Done extracting frames.")


def main():
    parser = argparse.ArgumentParser(
        description="Extract N evenly spaced frames from a video in the same folder."
    )
    parser.add_argument(
        "--video",
        required=True,
        help="Name of the video file (e.g. myvideo.mp4) located in the current folder."
    )
    parser.add_argument(
        "--num_frames",
        type=int,
        required=True,
        help="Number of frames to extract (evenly spaced across the video)."
    )
    args = parser.parse_args()

    video_filename = args.video
    num_frames     = args.num_frames

    # Check that the video file exists in the current folder
    cwd = os.getcwd()
    video_path = os.path.join(cwd, video_filename)
    if not os.path.isfile(video_path):
        print(f"Error: Video file '{video_filename}' not found in:\n    {cwd}")
        sys.exit(1)

    # Build output directory name, e.g. "myvideo_frames"
    base_name, _ = os.path.splitext(video_filename)
    output_dir = os.path.join(cwd, f"{base_name}_frames")

    # Create the folder if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    try:
        extract_evenly_spaced_frames(video_path, output_dir, num_frames)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
