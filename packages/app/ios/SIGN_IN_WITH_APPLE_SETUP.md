# iOS Sign In with Apple - Configuração Obrigatória

## ⚠️ IMPORTANTE: Configuração Manual no Xcode

Para que o Sign In with Apple funcione corretamente, você **DEVE** habilitar a capability no Xcode. Este é um passo obrigatório da Apple.

---

## 📋 Passo a Passo

### 1. Abrir o Projeto no Xcode

```bash
cd ios
open Runner.xcworkspace
```

### 2. Habilitar Sign In with Apple Capability

1. No **Project Navigator** (painel esquerdo), selecione o target **Runner**
2. Clique na aba **Signing & Capabilities**
3. Clique no botão **+ Capability** (no topo)
4. Procure e adicione **Sign In with Apple**

Após adicionar, você verá a capability listada com status **Enabled**.

### 3. Verificar Bundle Identifier

Certifique-se de que o **Bundle Identifier** está correto:

- **Atual:** `com.example.toSemBanda`
- Este ID deve estar registrado no Apple Developer Portal

### 4. Configurar Apple Developer Portal (Obrigatório)

⚠️ **Requer conta Apple Developer Program ($99/ano)**

1. Acesse [developer.apple.com](https://developer.apple.com)
2. Vá para **Certificates, Identifiers & Profiles**
3. Selecione **Identifiers** → Seu App ID
4. Habilite **Sign In with Apple**
5. Configure:
   - **Enable as a primary App ID** (padrão)
   - Salve as alterações

### 5. Atualizar Provisioning Profile

Após habilitar no Developer Portal:

1. No Xcode, vá para **Signing & Capabilities**
2. Clique em **Download Manual Profiles** (se necessário)
3. Ou deixe o Xcode gerenciar automaticamente (recomendado)

---

## ✅ Verificação Rápida

Após configurar, verifique no Xcode:

```
Signing & Capabilities → Sign In with Apple
Status: ✅ Enabled
```

---

## 🔐 Entitlements Gerados

O Xcode criará/atualizará automaticamente o arquivo `Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>

    <!-- Outras capabilities existentes -->
    <key>aps-environment</key>
    <string>development</string>
</dict>
</plist>
```

---

## 🧪 Testando Sign In with Apple

### Requisitos para Teste:

1. ✅ **Dispositivo físico iOS** (não funciona em simulador para Sign In with Apple real)
2. ✅ **Apple ID ativo** logado no dispositivo (Settings → Apple ID)
3. ✅ **Capability habilitada** no Xcode
4. ✅ **App ID configurado** no Developer Portal

### Como Testar:

1. Rode o app no dispositivo: `flutter run`
2. Na tela de login, clique em **"Continuar com Apple"**
3. Sistema mostrará prompt nativo do iOS
4. Escolha compartilhar ou ocultar email
5. Autentique com Face ID/Touch ID/senha
6. App receberá `identityToken` e `authorizationCode`

---

## 🚨 Troubleshooting

### Erro: "Sign In with Apple button não aparece"

**Causa:** App rodando em Android ou código não detectou iOS.

**Solução:** O botão só aparece em dispositivos iOS (`Platform.isIOS`).

---

### Erro: "The operation couldn't be completed"

**Causa:** Capability não habilitada no Xcode ou App ID não configurado.

**Solução:**

1. Verifique **Signing & Capabilities** no Xcode
2. Confirme que App ID está habilitado no Developer Portal
3. Faça rebuild completo: `flutter clean && flutter pub get && flutter run`

---

### Erro: "An error occurred during authorization"

**Causa:** Apple ID não configurado no dispositivo ou rede sem internet.

**Solução:**

1. Vá em Settings → Apple ID e faça login
2. Verifique conexão com internet
3. Tente novamente

---

### Simulador iOS não funciona

**Esperado:** Sign In with Apple tem limitações no simulador iOS. Para testes completos, use dispositivo físico.

**Simulador:** Apenas para testar UI do botão, mas a autenticação não funcionará.

---

## 📚 Recursos Adicionais

- [Apple Sign In Documentation](https://developer.apple.com/documentation/sign_in_with_apple)
- [Firebase + Apple Sign In](https://firebase.google.com/docs/auth/ios/apple)
- [sign_in_with_apple Package](https://pub.dev/packages/sign_in_with_apple)

---

## 🎯 Checklist de Implementação

- [ ] Dependência `sign_in_with_apple: ^6.1.3` adicionada ao `pubspec.yaml`
- [ ] Capability **Sign In with Apple** habilitada no Xcode
- [ ] App ID configurado no Apple Developer Portal
- [ ] Método `signInWithApple()` implementado em `AuthService`
- [ ] Botão `SignInWithAppleButton` adicionado em `AuthPage`
- [ ] Testado em dispositivo físico iOS
- [ ] Firebase recebe credencial Apple corretamente

---

**Status:** ✅ Implementação completa no código. **Pendente:** Configuração manual no Xcode (requer Apple Developer account).
