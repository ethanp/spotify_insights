#!/usr/bin/env python3
"""
Generates macOS app icons for Spotify Insights.

Usage:
    python3 scripts/generate_icon.py

Requirements:
    pip install Pillow
"""

from PIL import Image, ImageDraw
from pathlib import Path

# Spotify brand colors
SPOTIFY_GREEN = (29, 185, 84)       # #1DB954
SPOTIFY_GREEN_LIGHT = (30, 215, 96) # #1ED760
DARK_BG = (18, 18, 18)              # #121212
DARK_BG_LIGHT = (40, 40, 40)        # #282828

# Bar chart configuration
BAR_HEIGHTS = [0.30, 0.55, 0.40, 0.70, 0.50]  # Relative heights (0-1)


def create_icon(size: int) -> Image.Image:
    """Create a single icon at the specified size."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    radius = size // 2 - max(1, size // 64)
    
    # Draw circular gradient background
    for r in range(radius, 0, -1):
        ratio = r / radius
        c = int(DARK_BG[0] + (DARK_BG_LIGHT[0] - DARK_BG[0]) * (1 - ratio))
        draw.ellipse(
            [center - r, center - r, center + r, center + r],
            fill=(c, c + 2, c, 255)
        )
    
    # Bar chart dimensions
    bar_width = max(2, size // 7)
    gap = max(1, size // 12)
    base_y = int(size * 0.73)
    start_x = int(size * 0.17)
    max_height = int(size * 0.50)
    
    # Draw bars
    for i, height_ratio in enumerate(BAR_HEIGHTS):
        x = start_x + i * (bar_width + gap)
        bar_height = max(2, int(max_height * height_ratio))
        y = base_y - bar_height
        
        # Gradient fill for each bar
        for row in range(bar_height):
            ratio = row / max(1, bar_height)
            g = int(SPOTIFY_GREEN[1] + (SPOTIFY_GREEN_LIGHT[1] - SPOTIFY_GREEN[1]) * ratio)
            draw.rectangle(
                [x, y + row, x + bar_width - 1, y + row + 1],
                fill=(SPOTIFY_GREEN[0], g, SPOTIFY_GREEN[2], 255)
            )
        
        # Rounded cap on top of bar
        if bar_width > 3:
            cap_radius = bar_width // 4
            draw.ellipse(
                [x, y - cap_radius, x + bar_width - 1, y + cap_radius],
                fill=(*SPOTIFY_GREEN_LIGHT, 255)
            )
    
    return img


def generate_all_icons():
    """Generate icons for all required macOS sizes."""
    script_dir = Path(__file__).parent
    output_dir = script_dir.parent / 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
    
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    for size in sizes:
        icon = create_icon(size)
        output_path = output_dir / f'app_icon_{size}.png'
        icon.save(output_path, 'PNG')
        print(f'✓ {size}x{size} → {output_path.name}')
    
    print(f'\nIcons saved to: {output_dir}')


if __name__ == '__main__':
    generate_all_icons()

