#!/usr/bin/env python3
import re

file_path = r'd:\txData\Qbox_F0E98A.base\resources\[standalone]\scriptcreator\html\index.html'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix feature-card onclick handlers
replacements = [
    # Quick Start cards
    ('<div class="feature-card">\n                                 <strong>Player Actions</strong>', 
     '<div class="feature-card" onclick="setActivePanel(\'jobs\');">\n                                 <strong>Player Actions</strong>'),
    
    ('<div class="feature-card">\n                                 <strong>Vehicle Actions</strong>', 
     '<div class="feature-card" onclick="setActivePanel(\'jobs\');">\n                                 <strong>Vehicle Actions</strong>'),
    
    ('<div class="feature-card">\n                                 <strong>Zone Types</strong>', 
     '<div class="feature-card" onclick="setActivePanel(\'zones\');">\n                                 <strong>Zone Types</strong>'),
    
    ('<div class="feature-card">\n                                 <strong>Community Jobs</strong>', 
     '<div class="feature-card" onclick="setActivePanel(\'community\');">\n                                 <strong>Community Jobs</strong>'),
    
    # Community jobs cards
    ('<div class="community-card"><strong>Bahama - Gabz</strong>',
     '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Bahama - Gabz</strong>'),
    
    ('<div class="community-card"><strong>Burgershot - Gabz</strong>',
     '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Burgershot - Gabz</strong>'),
    
    ('<div class="community-card"><strong>Police - Gabz</strong>',
     '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Police - Gabz</strong>'),
    
    ('<div class="community-card"><strong>Winery - Dolu</strong>',
     '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Winery - Dolu</strong>'),
]

for old, new in replacements:
    if old in content:
        content = content.replace(old, new)
        print(f"✓ Replaced: {old[:50]}...")
    else:
        print(f"✗ Not found: {old[:50]}...")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('\n✅ All replacements completed!')
