#!/usr/bin/env python3
"""
screenshot_random_frames.py
·Script de python que obte N imatges a partir d'un video d'entrada,
i les guarda en un nova carpeta.
·Exemple d'us: python extract_frames.py --video myvideo.mp4 --num_frames 10
·Dependencies: pip install opencv-python
"""

import os
import sys
import argparse
import cv2


def extract_evenly_spaced_frames(video_path, output_dir, num_frames):

    base_name = os.path.splitext(os.path.basename(video_path))[0]
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise IOError(f"Cannot open video file: {video_path}")

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total_frames <= 0:
        raise ValueError("Unable to retrieve frame count or video is empty.")

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

    for count, frame_idx in enumerate(indices, start=1):
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
        ret, frame = cap.read()
        if not ret:
            print(f"Warning: could not read frame {frame_idx}. Skipping.")
            continue

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

    cwd = os.getcwd()
    video_path = os.path.join(cwd, video_filename)
    if not os.path.isfile(video_path):
        print(f"Error: Video file '{video_filename}' not found in:\n    {cwd}")
        sys.exit(1)

    base_name, _ = os.path.splitext(video_filename)
    output_dir = os.path.join(cwd, f"{base_name}_frames")
    os.makedirs(output_dir, exist_ok=True)

    try:
        extract_evenly_spaced_frames(video_path, output_dir, num_frames)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
