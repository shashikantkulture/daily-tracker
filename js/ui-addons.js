// js/ui-addons.js
import { calculateROI } from './dashboard.js';

export function showValueCalculator(stats) {
    const { postsVal, reelsVal, total } = calculateROI(stats);
    
    // Create popup element matching theme
    const popup = document.createElement('div');
    popup.style = `
        position: fixed; top: 20px; right: 20px; 
        background: linear-gradient(135deg, #1d4ed8, #2563eb);
        color: white; padding: 2rem; border-radius: 20px; 
        box-shadow: 0 20px 50px rgba(0,0,0,0.5); z-index: 10000;
        animation: slideIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
        max-width: 320px; border: 1px solid rgba(255,255,255,0.2);
    `;
    
    popup.innerHTML = `
        <div style="font-size: 2.5rem; margin-bottom: 0.5rem">🎉</div>
        <h3 style="font-size: 1.4rem; font-weight: 800; margin-bottom: 0.5rem">You saved ₹${total.toLocaleString()} this month!</h3>
        <p style="font-size: 0.85rem; opacity: 0.9; line-height: 1.5">
            Breakdown:<br>
            • Posts: ₹${postsVal.toLocaleString()}<br>
            • Reels: ₹${reelsVal.toLocaleString()}
        </p>
        <button id="closeRoi" style="margin-top: 1.5rem; background: rgba(255,255,255,0.2); border: none; color: white; padding: 0.5rem 1rem; border-radius: 8px; cursor: pointer; font-weight: 700">Close</button>
    `;

    document.body.appendChild(popup);
    document.getElementById('closeRoi').onclick = () => popup.remove();
}

export function updatePackageTimer(packageData) {
    const start = new Date(packageData.start_date);
    const today = new Date();
    const expiry = new Date(start);
    expiry.setDate(expiry.getDate() + packageData.duration_days);
    
    const diffTime = expiry - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    const elapsed = today - start;
    const elapsedDays = Math.floor(elapsed / (1000 * 60 * 60 * 24));
    const progress = Math.min(100, Math.max(0, (elapsedDays / packageData.duration_days) * 100));
    
    return {
        diffDays: Math.max(0, diffDays),
        progress
    };
}
export function renderEmojiPicker(taskId, clientId, onSelect) {
    const emojis = ['👍', '😍', '🔥', '😐', '👎'];
    return emojis.map(e => `
        <span onclick="event.stopPropagation(); window.saveEmoji('${taskId}', '${clientId}', '${e}')" 
              style="cursor:pointer; font-size:1.1rem; filter:grayscale(1); transition:0.2s" 
              onmouseover="this.style.filter='none'" 
              onmouseout="this.style.filter='grayscale(1)'">${e}</span>
    `).join('');
}

export function renderReactions(reactions) {
    if (!reactions || !reactions.length) return '';
    const counts = reactions.reduce((acc, r) => {
        acc[r.emoji] = (acc[r.emoji] || 0) + 1;
        return acc;
    }, {});
    
    return Object.entries(counts).map(([emoji, count]) => `
        <span style="background:var(--card2); padding:2px 6px; border-radius:10px; font-size:0.75rem">
            ${emoji} ${count > 1 ? count : ''}
        </span>
    `).join(' ');
}
