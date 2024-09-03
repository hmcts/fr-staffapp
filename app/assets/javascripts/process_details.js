'use strict';

window.moj.Modules.JurisdictionModule = {
    init: function(countyJurisdictionId, applicationType) {
        this.countyJurisdictionId = countyJurisdictionId || 1;
        this.applicationType = applicationType;
        this.bindEvents();
        this.loadState();
    },

    bindEvents: function() {
        const jurisdictionRadios = document.querySelectorAll(`#jurisdiction_radios input[name="${this.applicationType}[jurisdiction_id]"]`);
        const formTypeN1Radio = document.querySelector('#form_type_n1_radio');
        const formTypeOther = document.querySelector('#other_radio');

        const self = this;

        jurisdictionRadios.forEach(function (radio) {
            radio.addEventListener('change', function() {
                self.toggleClaimType();
            });
        });

        formTypeN1Radio.addEventListener('change', function() {
            self.toggleRequiredAttributes(formTypeN1Radio.checked);
        });

        formTypeOther.addEventListener('change', function() {
            self.toggleRequiredAttributes(false);
        });
    },

    loadState: function() {
        const countyJurisdictionElement = document.querySelector(`#jurisdiction_${this.countyJurisdictionId}`);
        const formTypeN1Radio = document.querySelector('#form_type_n1_radio');
        const isCountyJurisdiction = countyJurisdictionElement?.checked;

        if (formTypeN1Radio) {
            formTypeN1Radio.disabled = !isCountyJurisdiction;
            this.toggleRequiredAttributes(formTypeN1Radio.checked);
        }
    },

    toggleClaimType: function() {
        const countyJurisdictionElement = document.querySelector(`#jurisdiction_${this.countyJurisdictionId}`);
        const formTypeN1Radio = document.querySelector('#form_type_n1_radio');
        const formTypeOther = document.querySelector('#other_radio');
        const claimTypes = [
            ...document.querySelectorAll('[id$="_claim_type_specified"]'),
            ...document.querySelectorAll('[id$="_claim_type_unspecified"]'),
            ...document.querySelectorAll('[id$="_claim_type_personal_injury"]')
        ].filter(el => el.id.match(/^(application|online_application)_claim_type/));

        const isCountyJurisdiction = countyJurisdictionElement?.checked;

        if (!isCountyJurisdiction) {
            formTypeOther.click();
        } else {
            formTypeN1Radio.click();
        }

        formTypeN1Radio.disabled = !isCountyJurisdiction;

        claimTypes.forEach(claimType => {
            claimType.disabled = !isCountyJurisdiction;
            claimType.checked = false;
        });
    },

    toggleRequiredAttributes: function(isRequired) {
        const claimTypes = [
            ...document.querySelectorAll('[id$="_claim_type_specified"]'),
            ...document.querySelectorAll('[id$="_claim_type_unspecified"]'),
            ...document.querySelectorAll('[id$="_claim_type_personal_injury"]')
        ].filter(el => el.id.match(/^(application|online_application)_claim_type/));

        claimTypes.forEach(claimType => {
            if (isRequired) {
                claimType.setAttribute('required', 'required');
            } else {
                claimType.removeAttribute('required');
            }
        });
    }
};
