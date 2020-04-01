var viewModel;
function generateQRcode(qrCode) {
    document.getElementById("qrcode").innerHTML = "";
    new QRCode(document.getElementById("qrcode"), {
        text: qrCode,
        width: 150,
        height: 150,
        colorDark: "#000000",
        colorLight: "#ffffff",
        correctLevel: QRCode.CorrectLevel.L
    });
}
var qrPopup = Ext.create('Ext.window.Window', {
    title: 'ReAuthenticate QR',
    height: 250,
    width: 300,
    draggable: false,
    resizable: false,
    border: 0,
    closeAction: 'method-hide',
    modal: true,
    padding: '22 0 0 0',
    listeners: {
        'beforeshow': function () {
            Ext.Ajax.request({
                url: 'api/generateqr',
                success: function (res) {
                    generateQRcode(res.responseText);
                }
            });
        },
        'beforehide': function () {
            document.getElementById("qrcode").innerHTML = '<i class="fa fa-spinner fa-spin fa-3x fa-fw"></i>';
        }
    },
    items: {
        xtype: 'component',
        html: '<div id="qrcode"><i class="fa fa-spinner fa-spin fa-3x fa-fw"></i></div>'
    }
});

Ext.define('ATA.view.LoginModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.login',
    data: {
        isLoading: false,
        Error: {
            isError: false,
            textError: "",
        },
        textError: "",
        email: "",
        password: "",
    },
})
Ext.application({
    name: 'ATA',
    launch: function () {
        Ext.create('Ext.window.Window', {
            viewModel: {
                type: 'login'
            },
            autoShow: true,
            height: 180,
            width: 400,
            layout: {
                type: 'fit'
            },
            listeners: {
                'afterrender': function () {
                    viewModel = this.getViewModel();
                },
            },
            iconCls: 'fa fa-key fa-lg',
            title: 'Welcome',
            closeAction: 'hide',
            closable: false,
            draggable: false,
            resizable: false,
            items: [
                {
                    xtype: 'form',
                    bodyPadding: 15,
                    defaults: {
                        xtype: 'textfield',
                        allowBlank: false,
                        selectOnFocus: true,
                        anchor: '100%',
                        labelWidth: 70,
                    },
                    items: [{
                        name: 'email',
                        id: 'txtEmail',
                        fieldLabel: 'Email',
                        bind: {
                            value: '{email}'
                        },
                    }, {
                        name: 'password',
                        id: 'txtPassword',
                        inputType: 'password',
                        fieldLabel: 'Password',
                        bind: {
                            value: '{password}'
                        },
                        enableKeyEvents: true,
                    }, {
                        xtype: 'container',
                        layout: {
                            type: 'vbox',
                            align: 'center'
                        },
                        items: [{
                            xtype: 'label',
                            cls: 'error',
                            bind: {
                                hidden: '{!Error.isError}',
                                text: '{Error.textError}'
                            }
                        }]
                    }],
                    dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'bottom',
                        layout: {
                            type: 'hbox',
                            pack: 'center'
                        },
                        items: [{
                            xtype: 'button',
                            width: 80,
                            bind: {
                                iconCls: '{isLoading?"fa fa-spinner fa-spin":"fa fa-sign-in-alt"}',
                                disabled: '{isLoading}'
                            },
                            text: 'Sign In',
                            handler: function () {
                                viewModel.set('isLoading', true)
                                Ext.Ajax.request({
                                    headers: {
                                        'Content-Type': 'application/x-www-form-urlencoded'
                                    },
                                    url: '/Login/SignIn',
                                    method: 'post',
                                    params: {
                                        jsonUser: Ext.JSON.encode({
                                            ...this.up('form').getValues(),
                                            ...{ "returnSecureToken": true },
                                        })
                                    },
                                    success: function (res) {
                                        viewModel.set('isLoading', false)
                                        var dataJson = JSON.parse(res.responseText);
                                        if (dataJson.success) window.location.href = dataJson.data;
                                        else {
                                            viewModel.set('Error', {
                                                isError: true,
                                                textError: dataJson.data,
                                            })
                                        }
                                    },
                                    failure: function (res) {
                                        viewModel.set('isLoading', false)
                                        viewModel.set('Error', {
                                            isError: true,
                                            textError: res.statusText,
                                        })
                                    }
                                });
                            },
                        }, {
                            xtype: 'button',
                            width: 100,
                            iconCls: 'fa fa-qrcode',
                            text: 'QR Code',
                            handler: function () {
                                qrPopup.show();
                            }
                        }]
                    }]
                }
            ]
        })
    }
});