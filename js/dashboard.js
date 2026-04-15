// js/dashboard.js
import supabase from './supabaseClient.js';

export async function fetchStats(clientId) {
    const { data, error } = await supabase
        .from('content_stats')
        .select('*')
        .eq('client_id', clientId)
        .single();
    
    if (error && error.code !== 'PGRST116') throw error;
    return data || { posts_count: 0, reels_count: 0 };
}

export function calculateROI(stats) {
    const POST_VAL = 100;
    const REEL_VAL = 350;
    
    const postsVal = stats.posts_count * POST_VAL;
    const reelsVal = stats.reels_count * REEL_VAL;
    const total = postsVal + reelsVal;
    
    return {
        postsVal,
        reelsVal,
        total
    };
}

export async function calculateConsistency(clientId) {
    // Basic logic: frequency of completed tasks in the last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const { data, count } = await supabase
        .from('tasks')
        .select('*', { count: 'exact' })
        .eq('client_id', clientId)
        .eq('status', 'completed')
        .gte('created_at', thirtyDaysAgo.toISOString());
        
    // Return a mock % for now or based on frequency
    return Math.min(100, (count || 0) * 5); // Example: 20 tasks = 100%
}
