import * as React from "react";
import { createFileRoute, useRouter } from "@tanstack/react-router";
import { supabase, getURL } from "../utils/supabase";
import Icon from "../components/Icon";

type AuthProvider = "google" | "github" | "gitlab" | "bitbucket" | "discord" | "azure" | "apple";
type LoginSearch = { redirect?: string };

export const Route = createFileRoute("/login")({
  validateSearch: (search): LoginSearch => search as LoginSearch,
  component: LoginComponent,
});

function LoginComponent() {
  const router = useRouter();
  const search = Route.useSearch();

  const [isSignUp, setIsSignUp] = React.useState(false);
  const [step, setStep] = React.useState<"email" | "otp">("email");
  const [email, setEmail] = React.useState("");
  const [firstName, setFirstName] = React.useState("");
  const [lastName, setLastName] = React.useState("");
  const [otpCode, setOtpCode] = React.useState("");
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  const toMessage = (err: unknown) =>
    err instanceof Error ? err.message : "Something went wrong";

  const handleOAuth = async (provider: AuthProvider) => {
    try {
      setError(null);
      const { error } = await supabase.auth.signInWithOAuth({
        provider: provider,
        options: {
          redirectTo: getURL(),
        },
      });
      if (error) throw error;
    } catch (err) {
      setError(toMessage(err));
    }
  };

  const handleEmailSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      if (isSignUp) {
        // Sign up with email (magic link or password-based)
        const { error } = await supabase.auth.signUp({
          email,
          password: Math.random().toString(36).slice(-12), // Generate random password
          options: {
            data: {
              first_name: firstName,
              last_name: lastName,
            },
            emailRedirectTo: `${getURL()}${search.redirect || "/"}`,
          },
        });
        if (error) throw error;
        alert("Check your email for the confirmation link!");
      } else {
        // Send email OTP
        const { error } = await supabase.auth.signInWithOtp({
          email,
        });
        if (error) throw error;
        setStep("otp");
      }
    } catch (err) {
      setError(toMessage(err));
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const { error } = await supabase.auth.verifyOtp({
        email,
        token: otpCode,
        type: "email",
      });
      if (error) throw error;
      router.navigate({ to: search.redirect || "/" });
    } catch (err) {
      setError(toMessage(err));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-[#1a1a1a] text-white">
      <div className="w-full max-w-md px-8">
        {/* Header */}
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-semibold mb-2">
            {isSignUp ? "Sign up" : "Welcome to FVS"}
          </h1>
          {!isSignUp && (
            <p className="text-gray-400">The new way to build software</p>
          )}
        </div>

        {/* Card Container */}
        <div className="bg-[#1f1f1f] border border-[#2a2a2a] rounded-lg p-6">
          <form onSubmit={step === "otp" ? handleVerifyOtp : handleEmailSubmit}>
            <div className="space-y-5">
              {/* Email and Name Fields Section */}
              <div className="space-y-5">
                {/* First and Last Name (only shown for sign up) */}
                {isSignUp && (
                  <div className="flex gap-4">
                    <div className="flex-1 flex flex-col gap-2">
                      <label
                        htmlFor="firstName"
                        className="text-sm font-semibold"
                      >
                        First name
                      </label>
                      <input
                        id="firstName"
                        type="text"
                        required
                        autoComplete="given-name"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        placeholder="Your first name"
                        className="w-full bg-[#0a0a0a] border border-[#2a2a2a] text-white py-2 px-3 rounded-md focus:border-[#4a4a4a] focus:outline-none transition-colors"
                      />
                    </div>
                    <div className="flex-1 flex flex-col gap-2">
                      <label
                        htmlFor="lastName"
                        className="text-sm font-semibold"
                      >
                        Last name
                      </label>
                      <input
                        id="lastName"
                        type="text"
                        required
                        autoComplete="family-name"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        placeholder="Your last name"
                        className="w-full bg-[#0a0a0a] border border-[#2a2a2a] text-white py-2 px-3 rounded-md focus:border-[#4a4a4a] focus:outline-none transition-colors"
                      />
                    </div>
                  </div>
                )}

                {/* Email Field */}
                <div className="flex flex-col gap-2">
                  <label htmlFor="email" className="text-sm font-semibold">
                    Email
                  </label>
                  <input
                    id="email"
                    type="email"
                    required
                    autoComplete="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Your email address"
                    disabled={step === "otp"}
                    className="w-full bg-[#0a0a0a] border border-[#2a2a2a] text-white py-2 px-3 rounded-md focus:border-[#4a4a4a] focus:outline-none transition-colors"
                  />
                </div>

                {step === "otp" && !isSignUp && (
                  <div className="flex flex-col gap-2">
                    <label htmlFor="otp" className="text-sm font-semibold">
                      6-digit code
                    </label>
                    <input
                      id="otp"
                      type="text"
                      inputMode="numeric"
                      pattern="[0-9]*"
                      maxLength={6}
                      required
                      autoComplete="one-time-code"
                      value={otpCode}
                      onChange={(e) =>
                        setOtpCode(e.target.value.replace(/\D/g, ""))
                      }
                      placeholder="Enter the 6-digit code"
                      className="w-full bg-[#0a0a0a] border border-[#2a2a2a] text-white py-2 px-3 rounded-md focus:border-[#4a4a4a] focus:outline-none transition-colors tracking-[0.3em] text-center"
                    />
                  </div>
                )}

                {error && (
                  <div className="p-3 bg-red-900/20 border border-red-900/50 rounded-lg text-red-400 text-sm">
                    {error}
                  </div>
                )}

                {/* Submit Button */}
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-white hover:bg-gray-100 text-black font-medium py-2 px-4 rounded-md transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {loading
                    ? "Loading..."
                    : step === "otp"
                      ? "Verify code"
                      : isSignUp
                        ? "Continue"
                        : "Send email sign-in code"}
                </button>
              </div>

              {step === "email" && (
                <>
                  {/* OR Separator */}
                  <div className="relative flex items-center justify-center">
                    <div className="absolute w-full h-px bg-[#2a2a2a]"></div>
                    <span className="relative bg-[#1f1f1f] px-3 text-xs text-gray-500 uppercase">
                      OR
                    </span>
                  </div>

                  {/* OAuth Buttons */}
                  <div className="space-y-3">
                    <button
                      type="button"
                      onClick={() => handleOAuth("google")}
                      className="w-full bg-[#0a0a0a] hover:bg-[#151515] border border-[#2a2a2a] text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center gap-3"
                    >
                      <img
                        src="https://www.google.com/favicon.ico"
                        alt="Google"
                        className="w-4 h-4"
                      />
                      <span className="text-sm">Continue with Google</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => handleOAuth("github")}
                      className="w-full bg-[#0a0a0a] hover:bg-[#151515] border border-[#2a2a2a] text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center gap-3"
                    >
                      <Icon name="github" className="text-base" />
                      <span className="text-sm">Continue with GitHub</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => handleOAuth("apple")}
                      className="w-full bg-[#0a0a0a] hover:bg-[#151515] border border-[#2a2a2a] text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center gap-3"
                    >
                      <Icon name="apple" className="text-base" />
                      <span className="text-sm">Continue with Apple</span>
                    </button>
                  </div>
                </>
              )}
            </div>
          </form>

          {step === "otp" && !isSignUp && (
            <button
              type="button"
              onClick={() => handleEmailSubmit({ preventDefault: () => { } } as React.FormEvent<HTMLFormElement>)}
              className="w-full mt-4 text-sm text-gray-400 hover:text-white transition-colors"
            >
              Resend code
            </button>
          )}

          {step === "otp" && !isSignUp && (
            <button
              type="button"
              onClick={() => {
                setStep("email");
                setOtpCode("");
                setError(null);
              }}
              className="w-full mt-4 text-sm text-gray-400 hover:text-white transition-colors"
            >
              Go back
            </button>
          )}

          {/* Toggle Sign In / Sign Up */}
          <p className="text-center text-sm text-gray-400 mt-5">
            {isSignUp ? (
              <>
                Already have an account?{" "}
                <button
                  onClick={() => {
                    setIsSignUp(false);
                    setStep("email");
                    setOtpCode("");
                    setError(null);
                  }}
                  className="text-white hover:underline"
                >
                  Sign in
                </button>
              </>
            ) : (
              <>
                Don't have an account?{" "}
                <button
                  onClick={() => {
                    setIsSignUp(true);
                    setStep("email");
                    setOtpCode("");
                    setError(null);
                  }}
                  className="text-white hover:underline"
                >
                  Sign up
                </button>
              </>
            )}
          </p>
        </div>
      </div>
    </div>
  );
}
