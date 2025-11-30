const express = require('express');
const axios = require('axios');
const router = express.Router();

const PYTHON_URL = process.env.PYTHON_API_URL || 'http://localhost:5000';

console.log(`[Node.js] API Gateway initialized. Python Service URL: ${PYTHON_URL}`);

// Helper function to proxy requests to Python
async function proxyToPython(method, endpoint, req, res) {
    try {
        console.log(`[Node.js] Forwarding ${method} ${endpoint} to Python...`);
        const url = `${PYTHON_URL}${endpoint}`;

        let response;
        if (method === 'POST') {
            response = await axios.post(url, req.body);
        } else if (method === 'GET') {
            response = await axios.get(url, { params: req.query });
        }

        res.status(response.status).json(response.data);
    } catch (error) {
        const errorMsg = error.response ? error.response.data : error.message;
        console.error(`[Node.js] Error forwarding to Python (${endpoint}):`, errorMsg);
        res.status(error.response ? error.response.status : 500).json({
            message: "Error communicating with AI Service",
            error: errorMsg
        });
    }
}

// --- AI Endpoints (Proxy to Python) ---

router.post('/chat', (req, res) => {
    proxyToPython('POST', '/chat', req, res);
});

router.post('/search', (req, res) => {
    proxyToPython('POST', '/search', req, res);
});

router.post('/recommend', (req, res) => {
    proxyToPython('POST', '/recommend', req, res);
});

// Backward compatibility for GET /recommend/:type
router.get('/recommend/:type', async (req, res) => {
    // Convert GET params to POST body for Python
    const { type } = req.params;
    const { min, max } = req.query;

    try {
        console.log(`[Node.js] Converting GET /recommend/${type} to POST /recommend for Python...`);
        const response = await axios.post(`${PYTHON_URL}/recommend`, {
            type: type,
            min_price: parseInt(min) || 0,
            max_price: parseInt(max) || 1000000000
        });
        res.status(200).json(response.data);
    } catch (error) {
        console.error(`[Node.js] Error forwarding recommendation:`, error.message);
        res.status(500).json({ error: "Failed to fetch recommendations" });
    }
});

router.post('/compare', (req, res) => {
    proxyToPython('POST', '/compare', req, res);
});

module.exports = router;
