 
/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useState } from "react";
import { supabase, getURL } from "../utils/supabase";
import Icon from "./Icon";

interface AuthModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const AuthModal: React.FC<AuthModalProps> = ({ isOpen, onClose }) => {
  const [isSignUp, setIsSignUp] = useState(false);
  const [step, setStep] = useState("email");
  const [email, setEmail] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [otpCode, setOtpCode] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [otpNotice, setOtpNotice] = useState("");

  if (!isOpen) return null;

  const resetState = () => {
    setIsSignUp(false);
    setStep("email");
    setEmail("");
    setFirstName("");
    setLastName("");
    setOtpCode("");
    setError(null);
    setOtpNotice("");
    setLoading(false);
  };

  const handleClose = () => {
    resetState();
    onClose();
  };

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setOtpNotice("");

    try {
      if (isSignUp) {
        // Sign up with email
        const { error } = await supabase.auth.signUp({
          email,
          password: Math.random().toString(36).slice(-12), // Generate random password
          options: {
            data: {
              first_name: firstName,
              last_name: lastName,
            },
          },
        });
        if (error) throw error;
        alert("Check your email for the confirmation link!");
        handleClose();
      } else {
        await handleSendOtp();
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const handleSendOtp = async () => {
    setLoading(true);
    setError(null);
    setOtpNotice("");

    try {
      const { error } = await supabase.auth.signInWithOtp({ email });
      if (error) throw error;
      setOtpNotice("Check your email for the 6-digit code.");
      setStep("otp");
    } catch (err: any) {
      setError(err.message || 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setOtpNotice("");

    try {
      const { error } = await supabase.auth.verifyOtp({
        email,
        token: otpCode,
        type: "email",
      });
      if (error) throw error;
      handleClose();
    } catch (err: any) {
      setError(err.message || 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const handleOAuth = async (provider: 'google' | 'apple' | 'github') => {
    try {
      setError(null);
      const { error } = await supabase.auth.signInWithOAuth({
        provider: provider,
        options: {
          redirectTo: getURL(),
        },
      });
      if (error) throw error;
    } catch (err: any) {
      setError(err.message || 'An error occurred');
    }
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-6">
      <div className="bg-[#1f1f1f] border border-[#2a2a2a] w-full max-w-md rounded-lg shadow-2xl">
        {/* Header */}
        <div className="p-4 border-b border-[#2a2a2a] flex justify-between items-center">
          <h2 className="text-lg font-semibold">
            {isSignUp ? "Sign up" : "Sign in"}
          </h2>
          <button
            onClick={handleClose}
            className="text-gray-400 hover:text-white transition-colors"
          >
            <Icon name="close" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6">
          <form
            onSubmit={
              step === "otp" ? handleVerifyOtp : handleEmailSubmit
            }
          >
            <div className="space-y-5">
              {/* Form Fields Section */}
              <div className="space-y-5">
                {/* First and Last Name (only shown for sign up) */}
                {isSignUp && (
                  <div className="flex gap-4">
                    <div className="flex-1 flex flex-col gap-2">
                      <label
                        htmlFor="auth-firstName"
                        className="text-sm font-semibold"
                      >
                        First name
                      </label>
                      <input
                        id="auth-firstName"
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
                        htmlFor="auth-lastName"
                        className="text-sm font-semibold"
                      >
                        Last name
                      </label>
                      <input
                        id="auth-lastName"
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
                  <label htmlFor="auth-email" className="text-sm font-semibold">
                    Email
                  </label>
                  <input
                    id="auth-email"
                    type="email"
                    required
                    autoComplete="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Your email address"
                    disabled={step === "otp"}
                    className="w-full bg-[#0a0a0a] border border-[#2a2a2a] text-white py-2 px-3 rounded-md focus:border-[#4a4a4a] focus:outline-none transition-colors disabled:opacity-60"
                  />
                </div>

                {step === "otp" && !isSignUp && (
                  <div className="flex flex-col gap-2">
                    <label htmlFor="auth-otp" className="text-sm font-semibold">
                      6-digit code
                    </label>
                    <input
                      id="auth-otp"
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

                {otpNotice && (
                  <div className="p-3 bg-emerald-900/20 border border-emerald-900/50 rounded-lg text-emerald-300 text-sm">
                    {otpNotice}
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
                    : step === "otp" && !isSignUp
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

                    {/* <button
                      type="button"
                      onClick={() => handleOAuth('github')}
                      className="w-full bg-[#0a0a0a] hover:bg-[#151515] border border-[#2a2a2a] text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center gap-3"
                    >
                      <Icon name="github" className="text-base" />
                      <span className="text-sm">Continue with GitHub</span>
                    </button> */}

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

          {/* Toggle Sign In / Sign Up */}
          <p className="text-center text-sm text-gray-400 mt-5">
            {isSignUp ? (
              <>
                Already have an account?{" "}
                <button
                  onClick={() => {
                    setIsSignUp(false);
                    setStep("email");
                    setError(null);
                    setOtpNotice("");
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
                    setError(null);
                    setOtpNotice("");
                  }}
                  className="text-white hover:underline"
                >
                  Sign up
                </button>
              </>
            )}
          </p>

          {step === "otp" && !isSignUp && (
            <button
              type="button"
              onClick={() => handleSendOtp()}
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
                setOtpNotice("");
              }}
              className="w-full mt-4 text-sm text-gray-400 hover:text-white transition-colors"
            >
              Go back
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default AuthModal;
