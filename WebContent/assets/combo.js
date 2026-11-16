const comboForm = document.querySelector('#addCombo');
const selectedBody = document.querySelector('#selectedDishes');
const results = document.querySelector('#searchResults');
const resultsWrap = document.querySelector('#comboSearchResults');
// Mỗi mã món được chọn tương ứng với một dòng và một ô số lượng.
const selectedDishes = new Map();
const comboPrice = document.querySelector('#comboPrice');
const comboName = document.querySelector('#comboName');
const saveButton = document.querySelector('#saveCombo');
const saveMessage = document.querySelector('#saveMessage');
const imageInput = document.querySelector('#comboImage');
const previewImage = document.querySelector('#previewImage');
const imageMessage = document.querySelector('#imageMessage');
let previewUrl;
const searchForm = document.querySelector('#comboSearch');
const keyword = document.querySelector('#dishSearch');
const searchMessage = document.querySelector('#comboSearchMessage');
const searchButton = document.querySelector('#search');
let saving = false;

function showMessage(element, message) {
    element.textContent = message;
    element.hidden = !message;
}

function updateSaveButton() {
    const priceText = comboPrice.value.trim();
    const priceValue = Number(priceText.replaceAll('.', ''));
    const validPrice = /^(?:[0-9]+|[0-9]{1,3}(?:\.[0-9]{3})+)$/.test(priceText)
        && priceValue > 0 && priceValue <= 2147483647;
    const validQuantities = [...selectedDishes.values()].every(dish => dish.quantityInput.checkValidity());
    const canSave = comboName.value.trim() && validPrice && selectedDishes.size > 0
        && validQuantities && imageInput.checkValidity();

    saveButton.disabled = saving || !canSave;
}

function refreshSelectedDishes() {
    [...selectedDishes.values()].forEach((dish, index) => {
        dish.row.cells[0].textContent = index + 1;
    });
    if (!selectedDishes.size) {
        const row = selectedBody.insertRow();
        const cell = row.insertCell();
        cell.className = 'empty';
        cell.colSpan = 7;
        cell.textContent = 'No dishes selected';
    }
    refreshAddButtons();
    updateSaveButton();
}

function actionButton(text, label, action) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'button secondary compact';
    button.textContent = text;
    button.setAttribute('aria-label', label);
    button.addEventListener('click', action);
    return button;
}

function addDish(dish) {
    if (selectedDishes.has(dish.id)) return;
    if (!selectedDishes.size) selectedBody.replaceChildren();
    const row = selectedBody.insertRow();
    row.insertCell();
    [dish.code, dish.name, dish.price, dish.unit].forEach((text, index) => {
        const cell = row.insertCell();
        cell.textContent = text;
        if (index === 2) cell.className = 'numeric';
    });
    const quantityCell = row.insertCell();
    const controls = document.createElement('div');
    controls.className = 'quantity-controls';
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'dishId';
    idInput.value = dish.id;
    const quantity = document.createElement('input');
    quantity.type = 'number';
    quantity.name = 'quantity';
    quantity.min = '1';
    quantity.max = '999';
    quantity.value = '1';
    quantity.required = true;
    quantity.setAttribute('aria-label', 'Quantity for ' + dish.name);
    function changeQuantity(difference) {
        quantity.value = String(Math.min(999, Math.max(1, (quantity.valueAsNumber || 1) + difference)));
        updateSaveButton();
    }
    controls.append(idInput, actionButton('−', 'Decrease ' + dish.name, () => changeQuantity(-1)), quantity,
        actionButton('+', 'Increase ' + dish.name, () => changeQuantity(1)));
    quantityCell.append(controls);
    row.insertCell().append(actionButton('Del', 'Remove ' + dish.name, () => {
        row.remove();
        selectedDishes.delete(dish.id);
        refreshSelectedDishes();
    }));
    selectedDishes.set(dish.id, {row, quantityInput: quantity});
    refreshSelectedDishes();
}

async function searchDishes(event) {
    event.preventDefault();
    if (!keyword.value.trim()) {
        showMessage(searchMessage, 'Enter a dish or category');
        keyword.focus();
        return;
    }
    showMessage(searchMessage, '');
    searchButton.disabled = true;
    const params = new URLSearchParams(new FormData(searchForm));
    // JSP chỉ trả về các dòng kết quả để giữ dữ liệu đang nhập trên trang.
    params.set('fragment', '1');
    try {
        const response = await fetch(searchForm.action + '?' + params);
        if (response.redirected) {
            location.assign(response.url);
            return;
        }
        if (!response.ok) throw new Error('Search failed. Please try again.');
        results.innerHTML = await response.text();
        refreshAddButtons();
        resultsWrap.hidden = false;
    } catch (error) {
        showMessage(searchMessage, 'Search failed. Please try again.');
    } finally {
        searchButton.disabled = false;
    }
}

function refreshAddButtons() {
    for (const button of results.querySelectorAll('.add-dish')) {
        button.disabled = selectedDishes.has(button.dataset.id);
        button.textContent = button.disabled ? 'Added' : 'Add';
    }
}

function previewComboImage() {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    previewUrl = undefined;
    previewImage.removeAttribute('src');
    previewImage.hidden = true;

    const file = imageInput.files[0];
    const invalid = file && (file.size === 0 || file.size > 5 * 1024 * 1024
        || !['image/png', 'image/jpeg'].includes(file.type));
    const message = invalid ? 'Choose one PNG or JPEG image of up to 5 MB.' : '';
    imageInput.setCustomValidity(message);
    showMessage(imageMessage, message);
    if (file && !invalid) {
        previewUrl = URL.createObjectURL(file);
        previewImage.src = previewUrl;
        previewImage.hidden = false;
    }
    updateSaveButton();
}

async function saveCombo(event) {
    event.preventDefault();
    if (saving || saveButton.disabled || !comboForm.reportValidity()) return;
    const data = new FormData(comboForm);
    saving = true;
    updateSaveButton();
    showMessage(saveMessage, '');
    try {
        const response = await fetch(comboForm.action, {method: 'POST', body: data});
        if (response.redirected) {
            location.assign(response.url);
            return;
        }
        const message = (await response.text()).trim();
        if (response.ok && message === 'OK') {
            location.assign('ManageComboFrm1.jsp');
            return;
        }
        const inputError = [400, 409, 413].includes(response.status);
        showMessage(saveMessage, inputError && message ? message : 'Add new combo failed');
    } catch (error) {
        showMessage(saveMessage, 'Add new combo failed');
    } finally {
        saving = false;
        updateSaveButton();
    }
}

// Nối thao tác trên giao diện với các hàm xử lý ở trên.
searchForm.addEventListener('submit', searchDishes);
keyword.addEventListener('input', () => showMessage(searchMessage, ''));
results.addEventListener('click', event => {
    const button = event.target.closest('.add-dish');
    if (button) addDish(button.dataset);
});
imageInput.addEventListener('change', previewComboImage);
comboForm.addEventListener('input', updateSaveButton);
comboForm.addEventListener('submit', saveCombo);
