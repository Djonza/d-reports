document.addEventListener('DOMContentLoaded', () => {
    const playerContainer = document.getElementById('player-container');
    
    const adminContainer = document.getElementById('admin-container');
    const detailModal = document.getElementById('detail-modal');
    window.addEventListener('message', (event) => {
        const data = event.data;
        const mainContainer = document.getElementById('player-container');
        if (!mainContainer) {
            console.error("Element #main-container ne postoji u DOM-u.");
            return;
        }
        if (data.action === 'openPlayer') {
            document.body.style.display = 'flex';
            playerContainer.style.display = 'flex';
            adminContainer.style.display = 'none';
        } else if (data.action === 'openAdmin') {
            document.body.style.display = 'flex';
            playerContainer.style.display = 'none';
            adminContainer.style.display = 'block';
        } else if (data.action === 'updateReports') {
            updateReportList(data.reports);
        } else if (data.action === 'receiveMessage') {
            const chatMessages = document.getElementById('chat-messages');
            if (data.reportId === detailReportId.textContent) {
                const msgDiv = document.createElement('div');
                msgDiv.classList.add('message');
                const senderName = data.senderName || 'Nepoznat';
                msgDiv.innerHTML = `<span class="sender">${senderName}:</span> ${data.message}`;
                chatMessages.appendChild(msgDiv);
    
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }
        } else if (data.action === 'reportClosed') {
            detailModal.style.display = 'none';
        }
    });
});


document.addEventListener('DOMContentLoaded', () => {
    const sendReportBtn = document.getElementById('sendReportBtn');
    const playerContainer = document.getElementById('player-container')
    const closeNuiBtn = document.getElementById('closeNuiBtn');
    const closeAdminBtn = document.getElementById('closeAdminBtn');
    const tabs = document.querySelectorAll('.tab-btn');
    const messageTextarea = document.getElementById('report-message');
    const adminContainer = document.getElementById('admin-container');
    let selectedCategory = 'General'; 
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            selectedCategory = tab.getAttribute('data-category');
        });
    });

    sendReportBtn.addEventListener('click', () => {
        const message = messageTextarea.value.trim();
    
        sendReportBtn.classList.add('sending');
        if (!message) {
            fetch(`https://${GetParentResourceName()}/notifyEmptyMessage`, {
                method: 'POST'
            });
            sendReportBtn.classList.remove('sending');
            return;
        }
        fetch(`https://${GetParentResourceName()}/createReport`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ 
                category: selectedCategory, 
                message: message 
            })
        })
        .then(resp => resp.json())
        .then(resp => {
            messageTextarea.value = "";
            document.body.style.display = 'none';
            playerContainer.style.display = 'none';
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST'
            })
        })
        .catch(err => {
            console.error("Error:", err);
            sendReportBtn.classList.remove('sending');
        });
    });
    

    closeNuiBtn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST'
        }).then(() => {
            playerContainer.style.display = 'none';
        }).catch(err => {
            console.error("Eror while trying to close nui:", err);
        });
    });    
    closeAdminBtn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST'
        }).then(() => {
            adminContainer.style.display = 'none';
        }).catch(err => {
            console.error("Eror while trying to close nui:", err);
        });
    });
});


// ADMIN MENI REPORTS


document.addEventListener('DOMContentLoaded', () => {
    const tabs = document.querySelectorAll('.tab-btn');
    const detailModal = document.getElementById('detail-modal');
    const closeDetailBtn = document.getElementById('closeDetailBtn');
    const pregledajBtns = document.querySelectorAll('.pregledaj-btn');
    const detailPlayerName = document.getElementById('detail-playerName');
    const detailMessage = document.getElementById('detail-message');
    const gotoBtn = document.getElementById('gotoBtn');
    const bringBtn = document.getElementById('bringBtn');
    const closeReportBtn = document.getElementById('closeReportBtn');
tabs.forEach(tab => {
    tab.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        const category = tab.getAttribute('data-category');
        const rows = document.querySelectorAll('#report-list tr');
        rows.forEach(row => {
            const rowCat = row.getAttribute('data-category');
            if (category === 'General' || rowCat === category) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
});


pregledajBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        const tr = btn.closest('tr');
        const playerName = tr.getAttribute('data-playername');
        const message = tr.getAttribute('data-message');
        const playerId = tr.getAttribute('data-playerid');

        detailPlayerName.textContent = playerName;
        detailMessage.textContent = message;
        detailPlayerId.textContent = playerId; 

        detailModal.style.display = 'flex';
    });
});


closeDetailBtn.addEventListener('click', () => {
    detailModal.style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST'
    }).then(() => {
    }).catch(err => {
        console.error("Greška prilikom slanja zatvaranja NUI:", err);
    });
});

gotoBtn.addEventListener('click', () => {
    const playerIdElement = document.getElementById('detail-playerid');
    const playerId = playerIdElement.textContent.trim();

    fetch(`https://d-reportovi/gotoPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ playerId: playerId })
    })
    .catch(() => {});
});


bringBtn.addEventListener('click', () => {
    const playerIdElement = document.getElementById('detail-playerid');
    const playerId = playerIdElement.textContent.trim();

    fetch(`https://d-reportovi/bringPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ playerId: playerId })
    })
    .catch(() => {});
});

const detailReportId = document.getElementById('detail-reportId');

closeReportBtn.addEventListener('click', () => {
    const reportId = detailReportId.textContent.trim();


    fetch(`https://${GetParentResourceName()}/closeReport`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ reportId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const row = document.querySelector(`tr[data-reportid="${reportId}"]`);
            if (row) {
                row.remove(); 
                console.log(`Report  ${reportId} is deleted.`);
            } else {

            }
            detailModal.style.display = 'none';
        } else {
            console.log('Error while trying to close report')
        }
    })
    .catch(err => {
        console.error("Error while sending request for closing report:", err);
    });
});
});
const takeReportBtn = document.getElementById('takeReportBtn');
const detailReportId = document.getElementById('detail-reportId');

takeReportBtn.addEventListener('click', () => {
    const reportId = detailReportId.textContent;

    fetch(`https://${GetParentResourceName()}/takeReport`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reportId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateAdminInRow(reportId, data.adminName);
            takeReportBtn.style.display = 'none';
        } else {
            console.log(`Error while trying to take report with id: ${reportId}`);
        }
    })
    .catch(err => {
        console.error("Error while sending take report request:", err);
    });
});




function updateAdminInRow(reportId, adminName) {
    const row = document.querySelector(`tr[data-reportid="${reportId}"]`);
    if (row) {
        const adminCell = row.querySelector('td:nth-child(4)'); 
        if (adminCell) {
            adminCell.textContent = adminName;
        }
    }
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

function updateReportList(reports) {
    const tbody = document.getElementById('report-list');
    const detailPlayerName = document.getElementById('detail-playerName');
    const detailCategory = document.getElementById('detail-category');
    const detailModal = document.getElementById('detail-modal');
    const adminContainer = document.getElementById('admin-container');
    const detailPlayerId = document.getElementById('detail-playerid');
    const detailMessage = document.getElementById('detail-message');
    tbody.innerHTML = ''; 

    reports.forEach(report => {
        const tr = document.createElement('tr');
        tr.setAttribute('data-reportid', report.id);
        tr.setAttribute('data-playerid', report.player_id || 'N/A');
        tr.setAttribute('data-playername', report.sender_name);
        tr.setAttribute('data-message', report.message);
        tr.setAttribute('data-category', report.category);

        const tdPlayer = document.createElement('td');
        tdPlayer.textContent = `${report.sender_name || 'Unknown'} (${report.player_id || 'N/A'})`;
        tdPlayer.setAttribute('data-playerid', report.player_id || 'N/A');
        tr.appendChild(tdPlayer);
        
    
        const tdTime = document.createElement('td');
        tdTime.textContent = formatDate(report.time) || 'Unknown date';
        tr.appendChild(tdTime);

        const tdCategory = document.createElement('td');
        tdCategory.textContent = report.category || 'Unknown category';
        tr.appendChild(tdCategory);

        const tdAdmin = document.createElement('td');
        tdAdmin.textContent = report.admin_name || 'No admin';
        tr.appendChild(tdAdmin);

        
        const tdAction = document.createElement('td');
        const pregledBtn = document.createElement('button');
        pregledBtn.textContent = "View";
        pregledBtn.classList.add('btn-action');

        pregledBtn.addEventListener('click', () => {
            detailReportId.textContent = report.id;
            detailPlayerName.textContent = report.sender_name || 'Unknown';
            detailPlayerId.textContent = report.player_id || 'N/A';
            detailMessage.textContent = report.message || 'No message';
            detailCategory.textContent = report.category || 'Unknown';
        
            if (report.admin_name === "No admin") {
                takeReportBtn.style.display = 'inline-block';
            } else {
                takeReportBtn.style.display = 'none';
            }
        
            detailModal.style.display = 'flex';
            adminContainer.style.display = 'none';
        });
        

        tdAction.appendChild(pregledBtn);
        tr.appendChild(tdAction);
        tbody.appendChild(tr);
    });
}
