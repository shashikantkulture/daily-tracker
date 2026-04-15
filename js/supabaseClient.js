// js/supabaseClient.js
const SUPABASE_URL = 'https://fusaxujptvfukvqirtbv.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1c2F4dWpwdHZmdWt2cWlydGJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNTE1MTIsImV4cCI6MjA5MTgyNzUxMn0.DLgMeyfBG9oVPSvzMmkQqDxjKgkt9zoY3EVb67qOq7o';

const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

export default supabase;
