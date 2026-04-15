// js/timer.js
import supabase from './supabaseClient.js';

export async function startWork(clientId) {
    const { data, error } = await supabase
        .from('work_sessions')
        .insert([{ 
            client_id: clientId, 
            start_time: new Date().toISOString(),
            is_active: true 
        }])
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

export async function stopWork(sessionId) {
    const endTime = new Date();
    
    const { data: session } = await supabase
        .from('work_sessions')
        .select('*')
        .eq('id', sessionId)
        .single();
        
    if (!session) return;
    
    const startTime = new Date(session.start_time);
    const durationMinutes = (endTime - startTime) / 60000;
    
    const { error } = await supabase
        .from('work_sessions')
        .update({ 
            end_time: endTime.toISOString(),
            duration_minutes: durationMinutes,
            is_active: false
        })
        .eq('id', sessionId);
        
    if (error) throw error;
    return durationMinutes;
}

export async function getActiveSession(clientId) {
    const { data } = await supabase
        .from('work_sessions')
        .select('*')
        .eq('client_id', clientId)
        .eq('is_active', true)
        .maybeSingle();
    return data;
}
