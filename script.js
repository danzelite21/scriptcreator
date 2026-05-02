const endpoint = 'https://scriptcreator/action';
const toastTimeout = 3800;
let toastTimer = null;

window.addEventListener('message', (event) => {
    if (!event.data) return;
    if (event.data.action === 'setState') {
        renderState(event.data.payload);
    }
    if (event.data.action === 'toast') {
        showToast(event.data.payload.text, event.data.payload.type);
    }
    if (event.data.action === 'openMenu') {
        showUI();
        activateTab('create');
    }
    if (event.data.action === 'closeAll') {
        hideUI();
    }
});

function postAction(action, payload = {}) {
    fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ action, payload })
    });
}

function closeUI() {
    hideUI();
    fetch('https://scriptcreator/close', { method: 'POST' });
}

function showUI() {
    const app = document.querySelector('.app-shell');
    if (app) {
        app.classList.remove('hidden');
    }
}

function hideUI() {
    const app = document.querySelector('.app-shell');
    if (app) {
        app.classList.add('hidden');
    }
}

function activateTab(tab) {
    document.querySelectorAll('.tab').forEach((button) => {
        button.classList.toggle('active', button.dataset.tab === tab);
    });
    document.querySelectorAll('.tab-body').forEach((section) => {
        section.classList.toggle('active', section.id === tab);
    });
}

document.querySelectorAll('.tab').forEach((button) => {
    button.addEventListener('click', () => activateTab(button.dataset.tab));
});

document.querySelectorAll('.sidebar-item').forEach((button) => {
    button.addEventListener('click', () => setActivePanel(button.dataset.panel));
});

function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    toast.className = `toast ${type}`;
    toast.innerText = message;
    toast.classList.remove('hidden');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
        toast.classList.add('hidden');
    }, toastTimeout);
}

let jobGrades = [];
let jobActions = {};
let currentDragIndex = null;

function setActivePanel(panel) {
    document.querySelectorAll('.sidebar-item').forEach((button) => {
        button.classList.toggle('active', button.dataset.panel === panel);
    });
    document.querySelectorAll('.panel-content').forEach((content) => {
        content.classList.toggle('active', content.id === `panel-${panel}`);
    });
}

function selectCreateForm(form) {
    if (form === 'job') {
        setActivePanel('jobs');
    } else {
        showToast('Form belum tersedia di mode ini.', 'error');
    }
}

function addGrade() {
    const label = document.getElementById('gradeLabel').value;
    const salary = parseInt(document.getElementById('gradeSalary').value, 10);
    const boss = document.getElementById('gradeBoss').checked;
    if (!label || Number.isNaN(salary)) {
        showToast('Label dan Salary harus diisi dengan benar.', 'error');
        return;
    }
    jobGrades.push({ name: label, payment: salary, boss: boss });
    document.getElementById('gradeLabel').value = '';
    document.getElementById('gradeSalary').value = '';
    document.getElementById('gradeBoss').checked = false;
    renderGrades();
}

function removeGrade(index) {
    jobGrades.splice(index, 1);
    renderGrades();
}

function renderGrades() {
    const list = document.getElementById('gradesList');
    if (!list) return;
    list.innerHTML = '';
    jobGrades.forEach((grade, index) => {
        const li = document.createElement('li');
        li.draggable = true;
        li.dataset.index = index;
        li.innerHTML = `<span>${grade.name} · $${grade.payment} ${grade.boss ? '(Boss)' : ''}</span><button class="remove-grade" onclick="removeGrade(${index})">Remove</button>`;
        li.addEventListener('dragstart', () => {
            currentDragIndex = index;
            li.classList.add('dragging');
        });
        li.addEventListener('dragend', () => {
            li.classList.remove('dragging');
            currentDragIndex = null;
        });
        li.addEventListener('dragover', (event) => {
            event.preventDefault();
            li.classList.add('drag-over');
        });
        li.addEventListener('dragleave', () => {
            li.classList.remove('drag-over');
        });
        li.addEventListener('drop', (event) => {
            event.preventDefault();
            const targetIndex = Number(li.dataset.index);
            if (currentDragIndex === null || currentDragIndex === targetIndex) return;
            const moved = jobGrades.splice(currentDragIndex, 1)[0];
            jobGrades.splice(targetIndex, 0, moved);
            renderGrades();
        });
        list.appendChild(li);
    });
}

function saveActions() {
    jobActions = {
        handcuff: document.getElementById('actionHandcuff').checked,
        escort: document.getElementById('actionEscort').checked,
        search: document.getElementById('actionSearch').checked,
        carry: document.getElementById('actionCarry').checked,
        tackle: document.getElementById('actionTackle').checked,
        bill: document.getElementById('actionBill').checked,
        revive: document.getElementById('actionRevive').checked,
        heal: document.getElementById('actionHeal').checked,
        putInVehicle: document.getElementById('actionPutInVehicle').checked,
        takeOutVehicle: document.getElementById('actionTakeOutVehicle').checked,
        hijack: document.getElementById('actionHijack').checked,
        repair: document.getElementById('actionRepair').checked,
        clean: document.getElementById('actionClean').checked,
        impound: document.getElementById('actionImpound').checked
    };
    showToast('Actions saved.', 'success');
}

function renderState(state) {
    const listScriptOutput = document.getElementById('listScriptOutput');
    const listAdminOutput = document.getElementById('listAdminOutput');
    const auditOutput = document.getElementById('auditOutput');
    const statsOutput = document.getElementById('statsOutput');
    const adminListOutput = document.getElementById('adminListOutput');

    if (listScriptOutput) {
        listScriptOutput.innerHTML = '';
    }
    if (listAdminOutput) {
        listAdminOutput.innerHTML = '';
    }
    statsOutput.innerHTML = '';
    auditOutput.innerHTML = '';
    if (adminListOutput) {
        adminListOutput.innerHTML = '';
    }

    if (state.npcs && state.npcs.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>NPC</strong>';
        state.npcs.forEach((npc) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${npc.model}</strong> x:${npc.x.toFixed(1)} y:${npc.y.toFixed(1)} z:${npc.z.toFixed(1)} heading:${npc.heading}<br/><button onclick="postAction('deleteNPC',{id:${npc.id}})">Hapus NPC</button>`;
            group.appendChild(card);
        });
        if (listScriptOutput) {
            listScriptOutput.appendChild(group);
        }
    }
    if (state.blips && state.blips.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>Blip</strong>';
        state.blips.forEach((blip) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${blip.label}</strong> sprite:${blip.sprite} color:${blip.color} scale:${blip.scale}<br/><button onclick="postAction('deleteBlip',{id:${blip.id}})">Hapus Blip</button>`;
            group.appendChild(card);
        });
        if (listScriptOutput) {
            listScriptOutput.appendChild(group);
        }
    }
    if (state.markers && state.markers.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>Marker</strong>';
        state.markers.forEach((marker) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>Type ${marker.markerType}</strong> RGBA(${marker.r},${marker.g},${marker.b},${marker.a})<br/><button onclick="postAction('deleteMarker',{id:${marker.id}})">Hapus Marker</button>`;
            group.appendChild(card);
        });
        if (listScriptOutput) {
            listScriptOutput.appendChild(group);
        }
    }
    if (state.items && state.items.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>Items</strong>';
        state.items.forEach((item) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${item.label}</strong> (${item.name}) weight:${item.weight} stackable:${item.stackable == 1 ? 'Ya' : 'Tidak'}<br/><button onclick="postAction('deleteItem',{id:${item.id}})">Hapus Item</button> <button onclick="postAction('grantItem',{id:${item.id}})">Berikan Item</button>`;
            group.appendChild(card);
        });
        if (listScriptOutput) {
            listScriptOutput.appendChild(group);
        }
    }
    if (state.images && state.images.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>Images</strong>';
        state.images.forEach((image) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${image.label || 'Image'}</strong> ${image.url}<br/><button onclick="postAction('deleteImage',{id:${image.id}})">Hapus Image</button>`;
            group.appendChild(card);
        });
        if (listScriptOutput) {
            listScriptOutput.appendChild(group);
        }
    }

    if (state.jobs && state.jobs.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>Jobs</strong>';
        state.jobs.forEach((job) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${job.label}</strong> (${job.name})<br/>Type: ${job.type} - Default Duty: ${job.defaultDuty == 1 ? 'Ya' : 'Tidak'} - Off Duty Pay: ${job.offDutyPay == 1 ? 'Ya' : 'Tidak'}<br/>Webhook: ${job.webhook || '-'}<br/><button onclick="postAction('deleteJob',{id:${job.id}})">Hapus Job</button>`;
            group.appendChild(card);
        });
        if (listScriptOutput) {
            listScriptOutput.appendChild(group);
        }
    }

    if (state.admins && state.admins.length) {
        const group = document.createElement('div');
        group.innerHTML = '<strong>Admin Terdaftar</strong>';
        state.admins.forEach((admin) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${admin.name}</strong> ${admin.identifier}<br/><button onclick="postAction('removeAdmin',{identifier:'${admin.identifier}'})">Hapus Admin</button>`;
            group.appendChild(card);
        });
        if (listAdminOutput) {
            listAdminOutput.appendChild(group.cloneNode(true));
        }
        if (adminListOutput) {
            adminListOutput.appendChild(group.cloneNode(true));
        }
    } else {
        if (listAdminOutput) {
            listAdminOutput.innerHTML = '<div class="entry">Belum ada admin terdaftar.</div>';
        }
        if (adminListOutput) {
            adminListOutput.innerHTML = '<div class="entry">Belum ada admin terdaftar.</div>';
        }
    }

    if (state.stats) {
        for (const [key, value] of Object.entries(state.stats)) {
            const card = document.createElement('div');
            card.className = 'stats-card';
            card.innerHTML = `<strong>${key.toUpperCase()}</strong><div>${value}</div>`;
            statsOutput.appendChild(card);
        }
    }

    const logs = state.audit || [];
    if (logs.length) {
        logs.slice(0, 20).forEach((entry) => {
            const card = document.createElement('div');
            card.className = 'entry';
            card.innerHTML = `<strong>${entry.action}</strong> oleh ${entry.actor}<br/>Target: ${entry.target || '-'}<br/>${entry.created_at}`;
            auditOutput.appendChild(card);
        });
    }
}

function submitCreateNPC() {
    postAction('createNPC', {
        model: document.getElementById('npcModel').value,
        x: parseFloat(document.getElementById('npcX').value),
        y: parseFloat(document.getElementById('npcY').value),
        z: parseFloat(document.getElementById('npcZ').value),
        heading: parseFloat(document.getElementById('npcHeading').value),
        scenario: document.getElementById('npcScenario').value
    });
    showToast('Permintaan pembuatan NPC dikirim.', 'success');
}

function submitCreateBlip() {
    postAction('createBlip', {
        label: document.getElementById('blipLabel').value,
        sprite: parseInt(document.getElementById('blipSprite').value, 10),
        color: parseInt(document.getElementById('blipColor').value, 10),
        scale: parseFloat(document.getElementById('blipScale').value),
        x: parseFloat(document.getElementById('blipX').value),
        y: parseFloat(document.getElementById('blipY').value),
        z: parseFloat(document.getElementById('blipZ').value)
    });
    showToast('Permintaan pembuatan blip dikirim.', 'success');
}

function submitCreateMarker() {
    postAction('createMarker', {
        markerType: parseInt(document.getElementById('markerType').value, 10),
        r: parseInt(document.getElementById('markerR').value, 10),
        g: parseInt(document.getElementById('markerG').value, 10),
        b: parseInt(document.getElementById('markerB').value, 10),
        a: parseInt(document.getElementById('markerA').value, 10),
        x: parseFloat(document.getElementById('markerX').value),
        y: parseFloat(document.getElementById('markerY').value),
        z: parseFloat(document.getElementById('markerZ').value)
    });
    showToast('Permintaan pembuatan marker dikirim.', 'success');
}

function submitCreateItem() {
    postAction('createItem', {
        name: document.getElementById('itemName').value,
        label: document.getElementById('itemLabel').value,
        weight: parseFloat(document.getElementById('itemWeight').value),
        stackable: document.getElementById('itemStackable').value === '1'
    });
    showToast('Permintaan pembuatan item dikirim.', 'success');
}

function submitCreateImage() {
    postAction('createImage', {
        url: document.getElementById('imageUrl').value,
        label: document.getElementById('imageLabel').value,
        x: parseFloat(document.getElementById('imageX').value),
        y: parseFloat(document.getElementById('imageY').value),
        z: parseFloat(document.getElementById('imageZ').value),
        active: document.getElementById('imageActive').value === '1'
    });
    showToast('Permintaan pembuatan image dikirim.', 'success');
}

function submitAddAdmin() {
    postAction('addAdmin', {
        identifier: document.getElementById('adminIdentifier').value,
        name: document.getElementById('adminName').value
    });
    showToast('Permintaan tambah admin dikirim.', 'success');
}

function submitCreateJob() {
    let blips = [];
    let collections = [];
    let spawnerZones = [];
    let garages = [];
    try {
        blips = JSON.parse(document.getElementById('jobBlips').value || '[]');
        collections = JSON.parse(document.getElementById('jobCollections').value || '[]');
        spawnerZones = JSON.parse(document.getElementById('jobSpawnerZones').value || '[]');
        garages = JSON.parse(document.getElementById('jobGarages').value || '[]');
    } catch (e) {
        showToast('JSON tidak valid.', 'error');
        return;
    }
    postAction('createJob', {
        name: document.getElementById('jobName').value,
        label: document.getElementById('jobLabel').value,
        type: document.getElementById('jobType').value,
        defaultDuty: document.getElementById('jobDefaultDuty').checked,
        offDutyPay: document.getElementById('jobOffDutyPay').checked,
        webhook: document.getElementById('jobWebhook').value,
        grades: jobGrades,
        actions: jobActions,
        blips: blips,
        bossMenu: document.getElementById('jobBossMenu').value === '1',
        collections: collections,
        spawnerZones: spawnerZones,
        crafting: document.getElementById('jobCrafting').value === '1',
        garages: garages,
        selling: document.getElementById('jobSelling').value === '1'
    });
    showToast('Permintaan pembuatan job dikirim.', 'success');
}

function submitExport() {
    postAction('export');
    showToast('Permintaan export dikirim.', 'success');
}

document.querySelectorAll('.create-item').forEach((button) => {
    button.addEventListener('click', () => {
        const formId = button.dataset.form;
        document.querySelectorAll('.form-container').forEach((form) => {
            form.classList.add('hidden');
        });
        document.getElementById(`form-${formId}`).classList.remove('hidden');
    });
});

function setupSectionTabs() {
    document.querySelectorAll('.section-tab').forEach((button) => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            const sectionId = button.dataset.section;
            
            document.querySelectorAll('.section-tab').forEach((tab) => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.section-content').forEach((content) => {
                content.classList.add('hidden');
            });
            
            button.classList.add('active');
            const targetSection = document.getElementById(`section-${sectionId}`);
            if (targetSection) {
                targetSection.classList.remove('hidden');
            }
        });
    });
}

setupSectionTabs();

window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeUI();
    }
});
