const fs = require('fs');
const path = require('path');

const filePath = 'd:\\txData\\Qbox_F0E98A.base\\resources\\[standalone]\\scriptcreator\\html\\index.html';

let content = fs.readFileSync(filePath, 'utf-8');

const replacements = [
  // Quick Start cards  
  ['<div class="feature-card">\n                                 <strong>Player Actions</strong>',
   '<div class="feature-card" onclick="setActivePanel(\'jobs\');">\n                                 <strong>Player Actions</strong>'],
  
  ['<div class="feature-card">\n                                 <strong>Vehicle Actions</strong>',
   '<div class="feature-card" onclick="setActivePanel(\'jobs\');">\n                                 <strong>Vehicle Actions</strong>'],
  
  ['<div class="feature-card">\n                                 <strong>Zone Types</strong>',
   '<div class="feature-card" onclick="setActivePanel(\'zones\');">\n                                 <strong>Zone Types</strong>'],
  
  ['<div class="feature-card">\n                                 <strong>Community Jobs</strong>',
   '<div class="feature-card" onclick="setActivePanel(\'community\');">\n                                 <strong>Community Jobs</strong>'],
  
  // Community jobs cards
  ['<div class="community-card"><strong>Bahama - Gabz</strong>',
   '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Bahama - Gabz</strong>'],
  
  ['<div class="community-card"><strong>Burgershot - Gabz</strong>',
   '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Burgershot - Gabz</strong>'],
  
  ['<div class="community-card"><strong>Police - Gabz</strong>',
   '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Police - Gabz</strong>'],
  
  ['<div class="community-card"><strong>Winery - Dolu</strong>',
   '<div class="community-card" onclick="selectCreateForm(\'job\');"><strong>Winery - Dolu</strong>'],
];

replacements.forEach(([old, newVal]) => {
  if (content.includes(old)) {
    content = content.replace(old, newVal);
    console.log(`✓ Replaced: ${old.substring(0, 50)}...`);
  } else {
    console.log(`✗ Not found: ${old.substring(0, 50)}...`);
  }
});

fs.writeFileSync(filePath, content, 'utf-8');
console.log('\n✅ All replacements completed!');
