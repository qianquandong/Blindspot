import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.appLanguage) private var appLanguage

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var debugAccessToken: String = ""

    private let authAPI = AuthAPI()

    var body: some View {
        let t = { (en: String, zh: String) in SRL10n.t(en: en, zhHans: zh, lang: appLanguage) }

        return NavigationStack {
            VStack(spacing: 16) {
                Text("Blindspot")
                    .font(.largeTitle.bold())

                if SupabaseClientProvider.shared != nil {
                    Text(AppConfig.isMockMode
                         ? t("Connected to Supabase (Email OTP). Content is still local Demo (no custom API configured).", "已连接 Supabase（邮箱验证码登录）。内容仍为本地 Demo（未配置自建 API）。")
                         : t("Connected to Supabase (Email OTP).", "已连接 Supabase（邮箱验证码登录）。"))
                        .foregroundStyle(.secondary)
                } else {
                    Text(t("No backend configured. Please continue in local Demo mode.", "当前无后端：请进入本地 Demo 模式继续"))
                        .foregroundStyle(.secondary)
                }

                if SupabaseClientProvider.shared != nil {
                    NavigationLink {
                        EmailOTPLoginView()
                    } label: {
                        Text(t("Sign in with Email OTP", "邮箱验证码登录"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                }

#if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text(t("Local Demo (DEBUG)", "本地 Demo（DEBUG）"))
                        .font(.headline)

                    Button {
                        appState.authSession.setAccessToken("demo")
                        appState.subscriptionManager.tier = .pro
                    } label: {
                        Text(t("Enter with one tap (local data + Pro tier)", "一键进入（本地数据 + Pro 权限）"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)

                    Divider().padding(.vertical, 4)

                    TextField(t("Enter backend accessToken (Bearer token)", "输入后端 accessToken（Bearer token）"), text: $debugAccessToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    Button {
                        if debugAccessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            errorMessage = t("accessToken cannot be empty", "accessToken 不能为空")
                            return
                        }
                        appState.authSession.setAccessToken(debugAccessToken)
                    } label: {
                        Text(t("Sign in with accessToken", "使用 accessToken 登录"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
                .padding(.top, 8)
#endif

                Spacer()
            }
            .padding()
            .alert(t("Sign-in failed", "登录失败"), isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if !isPresented { errorMessage = nil }
                }
            )) {
                Button(t("OK", "知道了"), role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}

