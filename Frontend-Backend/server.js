const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const oracledb = require('oracledb');
const session = require('express-session');
const path = require('path');

const app = express();
const PORT = 3002;

app.use(cors({ origin: true, credentials: true }));
app.use(bodyParser.json());
app.use(session({ secret: 'football-club-secret', resave: false, saveUninitialized: true, cookie: { secure: false } }));

// Serve static HTML files
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'login.html'));
});

app.get('/login.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'login.html'));
});

app.get('/dashbord.html', (req, res) => {
    res.sendFile(path.join(__dirname, 'dashbord.html'));
});

// Oracle connection config - USING SYSTEM USER
function getDbConfig(role) {
    if (role === 'Manager') {
        return { 
            user: 'c##manager_user', 
            password: 'Manager123',
            connectString: 'localhost:1521/XE'
        };
    } else if (role === 'Agent') {
        return { 
            user: 'c##agent_user', 
            password: 'Agent123',
            connectString: 'localhost:1521/XE'
        };
    } else if (role === 'Analyst') {
        return { 
            user: 'c##analyst_user', 
            password: 'Analyst123',
            connectString: 'localhost:1521/XE'
        };
    }
}


// Login
app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    let role = '';
    
    if (username.includes('manager')) role = 'Manager';
    else if (username.includes('agent')) role = 'Agent';
    else if (username.includes('analyst')) role = 'Analyst';
    else return res.status(401).json({ success: false, message: 'Invalid username' });

    // Store user session
    req.session.user = { username, role, loggedIn: true };
    res.json({ success: true, role });
});

// Logout
app.post('/logout', (req, res) => { 
    req.session.destroy(); 
    res.json({ success: true }); 
});

// API to fetch data based on role
app.get('/api/data', async (req, res) => {
    // Check authentication
    if (!req.session.user || !req.session.user.loggedIn) {
        return res.status(401).json({ success: false, error: 'Not authenticated' });
    }

    const role = req.session.user.role;
    let view = '';
    
    // Determine which view to query based on role
    if (role === 'Manager') view = 'club_manager_view';
    else if (role === 'Agent') view = 'player_agent_view';
    else if (role === 'Analyst') view = 'match_analyst_view';

    let connection;
    try {
        // Get database config
        const dbConfig = getDbConfig(role);
        connection = await oracledb.getConnection(dbConfig);
        
        // Execute query - CHANGED FROM HALIMRM TO SYSTEM
const owner = 'HALIMRM'; // مالك الـ views
const result = await connection.execute(`SELECT * FROM ${owner}.${view}`);


        // Convert rows to objects
        const rows = result.rows.map(r => {
            let obj = {};
            result.metaData.forEach((col, i) => obj[col.name.toLowerCase()] = r[i]);
            return obj;
        });
        
        res.json({ success: true, data: rows });
    } catch(err) { 
        console.error('Database error:', err);
        res.status(500).json({ success: false, error: err.message }); 
    } finally { 
        if (connection) {
            try { 
                await connection.close(); 
            } catch(closeErr) {
                console.error('Error closing connection:', closeErr);
            }
        }
    }
});

app.listen(PORT, () => console.log(`✅ Server running on http://localhost:${PORT}`));