import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var debugAccessToken: String = ""

    private let authAPI = AuthAPI()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("StartupRadar")
                    .font(.largeTitle.bold())

                Text("当前无后端：请进入本地 Demo 模式继续")
                    .foregroundStyle(.secondary)

#if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text("本地 Demo（DEBUG）")
                        .font(.headline)

                    Button {
                        appState.authSession.setAccessToken("demo")
                        appState.subscriptionManager.tier = .pro
                    } label: {
                        Text("一键进入（本地数据 + Pro 权限）")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)

                    Divider().padding(.vertical, 4)

                    TextField("输入后端 accessToken（Bearer token）", text: $debugAccessToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    Button {
                        if debugAccessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            errorMessage = "accessToken 不能为空"
                            return
                        }
                        appState.authSession.setAccessToken(debugAccessToken)
                    } label: {
                        Text("使用 accessToken 登录")
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
            .alert("登录失败", isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if !isPresented { errorMessage = nil }
                }
            )) {
                Button("知道了", role: .cancel) { errorMessage = nil }
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

