const searchForm = document.querySelector('#dishSearch');

if (searchForm) {
    const keyword = document.querySelector('#searchBar');
    const button = document.querySelector('#btnSearch');
    const message = document.querySelector('#searchMessage');
    const showEmptySearch = () => {
        message.textContent = 'Enter a dish';
        message.hidden = false;
        keyword.setAttribute('aria-invalid', 'true');
        keyword.focus();
    };

    const syncSearchButton = () => {
        button.disabled = !keyword.value.trim();
        if (keyword.value.trim()) {
            message.hidden = true;
            keyword.removeAttribute('aria-invalid');
        }
    };
    button.disabled = !keyword.value.trim();
    keyword.addEventListener('input', syncSearchButton);
    keyword.addEventListener('keydown', event => {
        if (event.key === 'Enter' && !keyword.value.trim()) {
            event.preventDefault();
            showEmptySearch();
        }
    });
    searchForm.addEventListener('submit', event => {
        if (!keyword.value.trim()) {
            event.preventDefault();
            showEmptySearch();
        }
    });
    document.querySelector('#tblListDish')?.addEventListener('click', event => {
        const row = event.target.closest('[data-href]');
        if (row && !event.target.closest('a')) location.href = row.dataset.href;
    });
}

const editForm = document.querySelector('#editDish');
if (editForm) {
    const checkedFields = [...editForm.querySelectorAll('#tblDishInfo input, #tblDishInfo select')];
    const initial = checkedFields.map(field => field.value);
    const save = document.querySelector('#btnSave');
    const price = document.querySelector('#dishPrice');
    const message = document.querySelector('#editMessage');
    let saving = false;
    const updateSave = () => {
        const text = price.value.trim();
        const numeric = text.replaceAll('.', '');
        const validPrice = /^(?:[0-9]+|[0-9]{1,3}(?:\.[0-9]{3})+)$/.test(text)
            && Number(numeric) > 0 && Number(numeric) <= 2147483647;
        save.disabled = saving || !validPrice || !checkedFields.every(field => field.value.trim())
            || !checkedFields.some((field, i) => field.value !== initial[i]);
    };
    editForm.addEventListener('input', updateSave);
    editForm.addEventListener('change', updateSave);
    editForm.addEventListener('submit', async event => {
        event.preventDefault();
        if (saving || save.disabled) return;
        const data = new URLSearchParams(new FormData(editForm));
        saving = true;
        updateSave();
        message.hidden = true;
        const failure = 'Sửa thông tin món ăn thất bại';
        try {
            const response = await fetch(editForm.action, {
                method: 'POST',
                headers: {'X-RMS-Action': 'save-dish'},
                body: data
            });
            if (response.redirected) {
                location.assign(response.url);
                return;
            }
            const result = (await response.text()).trim();
            if (response.ok && result.startsWith('EditDishFrm1.jsp?')) {
                location.assign(result);
                return;
            }
            message.textContent = response.status === 400 ? result : failure;
            message.hidden = false;
        } catch (error) {
            message.textContent = failure;
            message.hidden = false;
        } finally {
            saving = false;
            updateSave();
        }
    });
    window.addEventListener('pageshow', updateSave);
}
