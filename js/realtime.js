// js/realtime.js
import supabase from './supabaseClient.js';

export function subscribeToClientData(clientId, onUpdate) {
    return supabase
        .channel(`client-${clientId}`)
        .on('postgres_changes', { 
            event: '*', 
            schema: 'public', 
            table: 'tasks', 
            filter: `client_id=eq.${clientId}` 
        }, onUpdate)
        .on('postgres_changes', { 
            event: '*', 
            schema: 'public', 
            table: 'work_sessions', 
            filter: `client_id=eq.${clientId}` 
        }, onUpdate)
        .on('postgres_changes', { 
            event: '*', 
            schema: 'public', 
            table: 'emoji_feedback', 
            filter: `client_id=eq.${clientId}` 
        }, onUpdate)
        .subscribe();
}

export function subscribeToAllData(onUpdate) {
    return supabase
        .channel('admin-global')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'tasks' }, onUpdate)
        .on('postgres_changes', { event: '*', schema: 'public', table: 'work_sessions' }, onUpdate)
        .on('postgres_changes', { event: '*', schema: 'public', table: 'emoji_feedback' }, onUpdate)
        .subscribe();
}
