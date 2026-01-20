import SwiftUI

struct EmailOTPLoginView: View {
    @EnvironmentObject private var appState: AppState

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
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("登录")
                    .font(.largeTitle.bold())

                Text("使用邮箱验证码登录（6 位）")
                    .foregroundStyle(.secondary)

                Group {
                    switch step {
                    case .enterEmail:
                        TextField("邮箱地址", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)

                        Button {
                            Task { await sendCode() }
                        } label: {
                            Text(isLoading ? "发送中…" : "发送验证码")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    case .enterCode:
                        Text("验证码已发送至：\(email)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        TextField("6 位验证码", text: $code)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            Task { await verifyCode() }
                        } label: {
                            Text(isLoading ? "验证中…" : "验证并登录")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading || code.trimmingCharacters(in: .whitespacesAndNewlines).count < 6)

                        Button("重新发送") {
                            Task { await sendCode() }
                        }
                        .disabled(isLoading)

                        Button("换个邮箱") {
                            step = .enterEmail
                            code = ""
                        }
                        .disabled(isLoading)
                    }
                }

                Spacer()
            }
            .padding()
            .alert("登录失败", isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in if !isPresented { errorMessage = nil } }
            )) {
                Button("知道了", role: .cancel) { errorMessage = nil }
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

