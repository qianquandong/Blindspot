import SwiftUI

struct EmailOTPLoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.appLanguage) private var appLanguage

    @State private var step: Step = .enterEmail
    @State private var email: String = ""
    @State private var code: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    enum Step {
        case enterEmail
        case enterCode
    }

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text(t("Sign in", "登录"))
                    .font(.largeTitle.bold())

                Text(t("Sign in with a 6-digit email code", "使用邮箱验证码登录（6 位）"))
                    .foregroundStyle(.secondary)

                Group {
                    switch step {
                    case .enterEmail:
                        TextField(t("Email address", "邮箱地址"), text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)

                        Button {
                            Task { await sendCode() }
                        } label: {
                            Text(isLoading ? t("Sending…", "发送中…") : t("Send code", "发送验证码"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    case .enterCode:
                        Text(String(format: t("Code sent to: %@", "验证码已发送至：%@"), email))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField(t("6-digit code", "6 位验证码"), text: $code)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            Task { await verifyCode() }
                        } label: {
                            Text(isLoading ? t("Verifying…", "验证中…") : t("Verify & sign in", "验证并登录"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || code.trimmingCharacters(in: .whitespacesAndNewlines).count < 6)

                        Button(t("Resend", "重新发送")) {
                            Task { await sendCode() }
                        }
                        .disabled(isLoading)

                        Button(t("Use a different email", "换个邮箱")) {
                            step = .enterEmail
                            code = ""
                        }
                        .disabled(isLoading)
                    }
                }

                Spacer()
            }
            .padding()
            .alert(t("Sign-in failed", "登录失败"), isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in if !isPresented { errorMessage = nil } }
            )) {
                Button(t("OK", "知道了"), role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func sendCode() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await appState.authManager.sendEmailOTP(to: email.trimmingCharacters(in: .whitespacesAndNewlines))
            step = .enterCode
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func verifyCode() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await appState.authManager.verifyEmailOTP(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                code: code.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

#Preview {
    EmailOTPLoginView()
        .environmentObject(AppState())
}

