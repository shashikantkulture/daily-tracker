// js/auth.js
import supabase from './supabaseClient.js';

/**
 * Checks if user is logged in and redirected based on role.
 * @param {string} expectedRole - 'admin' or 'client'
 */
export async function checkSession(expectedRole) {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (!session) {
        // Redirect to login if not on root/login page
        // But since index.html and client.html are the entry points, 
        // we show the login UI instead of locking the body.
        return null;
    }

    const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', session.user.id)
        .single();

    if (!profile) return null;

    // Direct URL protection
    const isAtAdminPage = window.location.pathname.endsWith('index.html') || window.location.pathname === '/';
    const isAtClientPage = window.location.pathname.endsWith('client.html') || window.location.pathname === '/client';

    if (profile.role === 'admin' && isAtClientPage) {
        window.location.href = 'index.html';
    } else if (profile.role === 'client' && isAtAdminPage) {
        window.location.href = 'client.html';
    }

    return { session, profile };
}

export async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    
    if (error) throw error;
    
    // Auth success - check profile for redirect
    const { data: profile, error: pError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', data.user.id)
        .maybeSingle();
        
    if (!profile || pError) {
        console.error("Profile check failed:", pError);
        // Fallback: If it's the admin email, allow entry (or at least don't crash)
        if (email === 'singhshashikant301@gmail.com') {
            window.location.href = 'index.html';
            return;
        }
        throw new Error("User profile not found. Please contact admin.");
    }
        
    if (profile.role === 'admin') {
        window.location.href = 'index.html';
    } else {
        window.location.href = 'client.html';
    }
}

export async function logout() {
    await supabase.auth.signOut();
    window.location.reload();
}
