SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict xAM2dVKVoTkeQMWy4tQma8SWPLTluQfZCZcgfbcEMwP9wsfDiUJI7ftZCONvltz

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'authenticated', 'authenticated', 'ed209m@gmail.com', NULL, '2026-01-09 12:44:20.123965+00', NULL, '', NULL, '', '2026-01-15 11:17:09.810276+00', '', '', NULL, '2026-01-24 04:35:23.911218+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "104496322802490062407", "name": "Clark Kent", "email": "ed209m@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIQXVdnrP_aB6yryjxn9OuNrhiFy4ZBClkbwlgtWQos14s7LZU=s96-c", "full_name": "Clark Kent", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIQXVdnrP_aB6yryjxn9OuNrhiFy4ZBClkbwlgtWQos14s7LZU=s96-c", "provider_id": "104496322802490062407", "email_verified": true, "phone_verified": false}', NULL, '2026-01-09 12:44:20.083653+00', '2026-01-24 11:40:07.082643+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'authenticated', 'authenticated', 'evan.meeks.cdk@gmail.com', NULL, '2026-01-09 12:00:21.928989+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-01-22 06:34:46.903706+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "101184419629744877499", "name": "Evan Meeks", "email": "evan.meeks.cdk@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK1tEHwc43yIFCHSPCrpTlHth_ilT75CJ8fBVF3Fe1KmZ-Gcg=s96-c", "full_name": "Evan Meeks", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK1tEHwc43yIFCHSPCrpTlHth_ilT75CJ8fBVF3Fe1KmZ-Gcg=s96-c", "provider_id": "101184419629744877499", "email_verified": true, "phone_verified": false}', NULL, '2026-01-09 12:00:21.891361+00', '2026-01-22 06:34:46.928485+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '9a5e5ad6-f9be-465a-a27f-a6f5a6679bfa', 'authenticated', 'authenticated', 'appreview@dinnafind.com', '$2a$10$aL.96RdIV0OqcFFMZcEK0.e9N75O0pQXENPUVYgtrg/G0ea6Mhgja', '2026-01-28 06:03:15.945448+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-01-28 06:03:15.889905+00', '2026-01-28 06:03:15.953319+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '15a0e973-4b17-4d14-aef4-3ee1f768ba44', 'authenticated', 'authenticated', 'hello@dinnafind.com', '$2a$10$JsrXemy9oqVzyGuALq0SiekMQGNhFgNU5CyfMYf.63fCz.4GWx4qi', NULL, NULL, '8462751e4e1c566bd6e736f7f2030d011d82dd85fd386eb62c85eef3', '2026-01-10 18:57:50.357727+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "15a0e973-4b17-4d14-aef4-3ee1f768ba44", "email": "hello@dinnafind.com", "email_verified": false, "phone_verified": false}', NULL, '2026-01-10 18:52:15.415326+00', '2026-01-10 18:57:50.524743+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '2bcf4386-383c-4fdd-8c4b-311bc6a85a77', 'authenticated', 'authenticated', 'fade.to.bass@gmail.com', '$2a$10$PADWjOrotZzMTWZU11yiMOInCyTbxs.lolzFkAz5gV4U6rJsEyasq', NULL, NULL, '43f7e680fbc3bae0758f346a935436fcf6dd5e8f886fac2a5579747e', '2026-01-10 18:51:56.677143+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "2bcf4386-383c-4fdd-8c4b-311bc6a85a77", "email": "fade.to.bass@gmail.com", "email_verified": false, "phone_verified": false}', NULL, '2026-01-10 18:51:56.640596+00', '2026-01-10 18:51:56.897745+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'a5734ec1-210b-4ee0-92f1-d0a99a280713', 'authenticated', 'authenticated', 'evanmeekscdk@gmail.com', NULL, '2026-01-10 17:15:39.184336+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-01-10 17:15:39.190552+00', '{"provider": "apple", "providers": ["apple"]}', '{"iss": "https://appleid.apple.com", "sub": "001574.efe9047a48da486bb7b05d1c76df4aa8.0330", "name": "Evan Meeks", "email": "evanmeekscdk@gmail.com", "full_name": "Evan Meeks", "provider_id": "001574.efe9047a48da486bb7b05d1c76df4aa8.0330", "custom_claims": {"auth_time": 1768065338}, "email_verified": true, "phone_verified": false}', NULL, '2026-01-10 17:15:39.137263+00', '2026-01-10 17:15:39.237356+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '73caa1d9-455a-43ce-ba81-f2b37242e748', 'authenticated', 'authenticated', 'evan.m.eeks@gmail.com', '$2a$10$huvfTA3pXL3ubxFrOez1LejMkd3Ag0rSR08h1I8ySXf9r9T7F8e8K', '2026-01-11 04:03:10.224697+00', NULL, '', '2026-01-11 04:02:57.834273+00', '', NULL, '', '', NULL, '2026-01-11 04:03:10.233703+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "73caa1d9-455a-43ce-ba81-f2b37242e748", "email": "evan.m.eeks@gmail.com", "last_name": "Meeks", "first_name": "Evan", "email_verified": true, "phone_verified": false}', NULL, '2026-01-11 04:02:57.792292+00', '2026-01-11 04:03:10.25235+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '2ceae342-cc8c-46c4-a6fd-b625f4471f8a', 'authenticated', 'authenticated', 'evan.m.e+eks@gmail.com', '$2a$10$5BlLfYyQMZ8cpPWr0LuMUu31T5qNoW9vcxlwkDNNewLzyQiqJzJVW', NULL, NULL, 'd7625f5b7dacfa67d965ce8cf8405c702e8422e4c6096c44f1fce474', '2026-01-11 04:07:23.441743+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "2ceae342-cc8c-46c4-a6fd-b625f4471f8a", "email": "evan.m.e+eks@gmail.com", "last_name": "Deeks", "first_name": "Evan", "email_verified": false, "phone_verified": false}', NULL, '2026-01-11 04:07:23.413392+00', '2026-01-11 04:07:23.583414+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '4f308a61-8fde-4783-b1a6-4f1712061da5', 'authenticated', 'authenticated', 'fadeto.bass@gmail.com', '$2a$10$XCr7.cPv71zYxIIxzE4vb.fKboXCn5tTISmhuoSnFDbKjFgljfGwu', '2026-01-15 03:58:28.716961+00', NULL, '', '2026-01-15 03:58:17.204217+00', '', NULL, '', '', NULL, '2026-01-15 03:58:28.722773+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "4f308a61-8fde-4783-b1a6-4f1712061da5", "email": "fadeto.bass@gmail.com", "last_name": "Dee", "first_name": "X", "email_verified": true, "phone_verified": false}', NULL, '2026-01-15 03:55:36.377592+00', '2026-01-15 03:58:28.737563+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'authenticated', 'authenticated', 'evanmeeks@gmail.com', '$2a$10$mvobnANuHLhm590eOmHOa.sMsvLZy3BY1q35TDv2BJqYsTRZ0NmZW', '2026-01-09 20:32:46.257894+00', NULL, '', '2026-01-09 20:32:08.439783+00', '', '2026-01-15 11:18:15.497357+00', '', '', NULL, '2026-01-15 11:18:35.048263+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "daf56408-129f-4ed7-9af5-1fefd84068ea", "email": "evanmeeks@gmail.com", "email_verified": true, "phone_verified": false}', NULL, '2026-01-09 20:32:08.422767+00', '2026-01-15 11:18:35.050528+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '7ddcaff5-b8e0-47cf-b904-3b9a53c37c41', 'authenticated', 'authenticated', 'e.van.meeks@gmail.com', '$2a$10$p0ua.U9SSUm4bBBRSPtVuuZkiYdjvI3wLBWSXMajJNJcM1PRFrtMG', '2026-01-11 04:47:29.311219+00', NULL, '', '2026-01-11 04:47:09.503244+00', '', '2026-01-13 09:47:32.270641+00', '', '', NULL, '2026-01-13 09:47:50.282984+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7ddcaff5-b8e0-47cf-b904-3b9a53c37c41", "email": "e.van.meeks@gmail.com", "last_name": "Deeks", "first_name": "Evan", "email_verified": true, "phone_verified": false}', NULL, '2026-01-11 04:47:09.494112+00', '2026-01-13 09:47:50.306287+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '8af556c0-d504-4f0d-99b5-aadfbe9a7107', 'authenticated', 'authenticated', 'hell.o@dinnafind.com', '$2a$10$2Cx.FLiSXEooDJR1sdDeT.BU9Ra9sQCmNpwDERLKMIe1xJc8oXWgq', NULL, NULL, 'd5076f3b1b0b3cb7ee807bb74d55be22d757d438e851c46375fe2633', '2026-01-11 04:19:38.293259+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "8af556c0-d504-4f0d-99b5-aadfbe9a7107", "email": "hell.o@dinnafind.com", "email_verified": false, "phone_verified": false}', NULL, '2026-01-11 04:19:38.27277+00', '2026-01-11 04:19:38.488484+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'authenticated', 'authenticated', 'evan.meeks@gmail.com', NULL, '2026-01-09 11:33:04.083665+00', NULL, '', NULL, '', '2026-01-12 23:56:07.102505+00', '', '', NULL, '2026-01-23 08:43:42.926161+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "108842097930565120749", "name": "Evan Meeks", "email": "evan.meeks@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIUEF_Zz2UhkT0nXwNBMTRd8EmHK6qWv5h5CxrRbQ61j91unVHmAg=s96-c", "full_name": "Evan Meeks", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIUEF_Zz2UhkT0nXwNBMTRd8EmHK6qWv5h5CxrRbQ61j91unVHmAg=s96-c", "provider_id": "108842097930565120749", "email_verified": true, "phone_verified": false}', NULL, '2026-01-09 11:33:04.036691+00', '2026-01-23 08:43:42.940287+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'authenticated', 'authenticated', 'fadetobass@gmail.com', NULL, '2026-01-09 11:29:09.480847+00', NULL, '', NULL, '', '2026-01-15 11:20:36.56955+00', '', '', NULL, '2026-01-23 05:23:30.35251+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "109924547882065640590", "name": "Randy Moncrief", "email": "fadetobass@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKQ2fQrEnzrdp5aeMyzSqg1B5ON_S4GZ3nIulyn24AdXKKSZ7M=s96-c", "full_name": "Randy Moncrief", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKQ2fQrEnzrdp5aeMyzSqg1B5ON_S4GZ3nIulyn24AdXKKSZ7M=s96-c", "provider_id": "109924547882065640590", "email_verified": true, "phone_verified": false}', NULL, '2026-01-09 11:29:09.455768+00', '2026-01-23 05:23:30.359843+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'authenticated', 'authenticated', 'ed209.m+@gmail.com', '$2a$10$4BAAsvBy4J1t45aXHYl9q.ebSrqkUm8apeZSk4YQCklEsGpgKZfMW', '2026-01-11 04:55:43.68252+00', NULL, '', '2026-01-11 04:54:38.286216+00', '', NULL, '', '', NULL, '2026-01-11 04:55:43.688394+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "286f27d8-00a1-43c5-a855-0f8fe153c423", "email": "ed209.m+@gmail.com", "email_verified": true, "phone_verified": false}', NULL, '2026-01-11 04:48:08.903763+00', '2026-01-11 05:54:30.755959+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '29df7fd8-624c-4103-bc83-8c7d6e85c0e0', 'authenticated', 'authenticated', 'e.van.mee.k.s@gmail.com', '$2a$10$A0nIn.IvZi8kiupTRjpuwekqkZ9b3hc3KPUwTzp1cjcb/DNqy5wMO', NULL, NULL, '799cc607ba84b5284bf136ef4e4acbb84bbad18e588d4293326e905c', '2026-01-11 04:54:03.708345+00', '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"sub": "29df7fd8-624c-4103-bc83-8c7d6e85c0e0", "email": "e.van.mee.k.s@gmail.com", "last_name": "CCC", "first_name": "D", "email_verified": false, "phone_verified": false}', NULL, '2026-01-11 04:54:03.68148+00', '2026-01-11 04:54:03.805547+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'd27f7741-bf91-4c6d-82bc-27b6e79284fb', 'authenticated', 'authenticated', 'e.vanmeeks@gmail.com', '$2a$10$qIsxXrTVgxmI6JC9.SEkluZz.KXNCOIc0rAe4pqLWEXd9QRXZ8jM2', '2026-01-11 04:45:22.688609+00', NULL, '', '2026-01-11 04:45:09.416588+00', '', NULL, '', '', NULL, '2026-01-11 04:45:22.694442+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "d27f7741-bf91-4c6d-82bc-27b6e79284fb", "email": "e.vanmeeks@gmail.com", "email_verified": true, "phone_verified": false}', NULL, '2026-01-11 04:43:11.341962+00', '2026-01-11 04:45:22.730704+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('d27f7741-bf91-4c6d-82bc-27b6e79284fb', 'd27f7741-bf91-4c6d-82bc-27b6e79284fb', '{"sub": "d27f7741-bf91-4c6d-82bc-27b6e79284fb", "email": "e.vanmeeks@gmail.com", "email_verified": true, "phone_verified": false}', 'email', '2026-01-11 04:43:11.377708+00', '2026-01-11 04:43:11.377757+00', '2026-01-11 04:43:11.377757+00', '63d3884a-7341-48be-a81a-bef5c3709177'),
	('109924547882065640590', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', '{"iss": "https://accounts.google.com", "sub": "109924547882065640590", "name": "Randy Moncrief", "email": "fadetobass@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKQ2fQrEnzrdp5aeMyzSqg1B5ON_S4GZ3nIulyn24AdXKKSZ7M=s96-c", "full_name": "Randy Moncrief", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKQ2fQrEnzrdp5aeMyzSqg1B5ON_S4GZ3nIulyn24AdXKKSZ7M=s96-c", "provider_id": "109924547882065640590", "email_verified": true, "phone_verified": false}', 'google', '2026-01-09 11:29:09.4758+00', '2026-01-09 11:29:09.475856+00', '2026-01-23 05:23:30.348013+00', '209b1731-5886-4ba5-a23a-e2d05bf2a371'),
	('001574.efe9047a48da486bb7b05d1c76df4aa8.0330', 'a5734ec1-210b-4ee0-92f1-d0a99a280713', '{"iss": "https://appleid.apple.com", "sub": "001574.efe9047a48da486bb7b05d1c76df4aa8.0330", "name": "Evan Meeks", "email": "evanmeekscdk@gmail.com", "full_name": "Evan Meeks", "provider_id": "001574.efe9047a48da486bb7b05d1c76df4aa8.0330", "custom_claims": {"auth_time": 1768065338}, "email_verified": true, "phone_verified": false}', 'apple', '2026-01-10 17:15:39.177729+00', '2026-01-10 17:15:39.177792+00', '2026-01-10 17:15:39.177792+00', 'd0a92b38-b213-44a8-a4c1-72820665f5e4'),
	('101184419629744877499', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', '{"iss": "https://accounts.google.com", "sub": "101184419629744877499", "name": "Evan Meeks", "email": "evan.meeks.cdk@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK1tEHwc43yIFCHSPCrpTlHth_ilT75CJ8fBVF3Fe1KmZ-Gcg=s96-c", "full_name": "Evan Meeks", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK1tEHwc43yIFCHSPCrpTlHth_ilT75CJ8fBVF3Fe1KmZ-Gcg=s96-c", "provider_id": "101184419629744877499", "email_verified": true, "phone_verified": false}', 'google', '2026-01-09 12:00:21.922217+00', '2026-01-09 12:00:21.92227+00', '2026-01-22 06:34:46.891603+00', 'b28eba37-f107-40ba-9997-22a6909ab503'),
	('daf56408-129f-4ed7-9af5-1fefd84068ea', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '{"sub": "daf56408-129f-4ed7-9af5-1fefd84068ea", "email": "evanmeeks@gmail.com", "email_verified": true, "phone_verified": false}', 'email', '2026-01-09 20:32:08.436726+00', '2026-01-09 20:32:08.436778+00', '2026-01-09 20:32:08.436778+00', '3ce336c4-42c4-4e88-8bc8-e0342fb488ae'),
	('2bcf4386-383c-4fdd-8c4b-311bc6a85a77', '2bcf4386-383c-4fdd-8c4b-311bc6a85a77', '{"sub": "2bcf4386-383c-4fdd-8c4b-311bc6a85a77", "email": "fade.to.bass@gmail.com", "email_verified": false, "phone_verified": false}', 'email', '2026-01-10 18:51:56.673107+00', '2026-01-10 18:51:56.673156+00', '2026-01-10 18:51:56.673156+00', '0294acba-f2d7-4dbf-a1b2-b23db8d58250'),
	('15a0e973-4b17-4d14-aef4-3ee1f768ba44', '15a0e973-4b17-4d14-aef4-3ee1f768ba44', '{"sub": "15a0e973-4b17-4d14-aef4-3ee1f768ba44", "email": "hello@dinnafind.com", "email_verified": false, "phone_verified": false}', 'email', '2026-01-10 18:52:15.419454+00', '2026-01-10 18:52:15.419514+00', '2026-01-10 18:52:15.419514+00', 'e7e51ad3-a60e-4e75-b177-173c7a9027a4'),
	('7ddcaff5-b8e0-47cf-b904-3b9a53c37c41', '7ddcaff5-b8e0-47cf-b904-3b9a53c37c41', '{"sub": "7ddcaff5-b8e0-47cf-b904-3b9a53c37c41", "email": "e.van.meeks@gmail.com", "last_name": "Deeks", "first_name": "Evan", "email_verified": true, "phone_verified": false}', 'email', '2026-01-11 04:47:09.500878+00', '2026-01-11 04:47:09.500927+00', '2026-01-11 04:47:09.500927+00', '1682dd9a-34fb-472c-ab64-d7d403e6305c'),
	('73caa1d9-455a-43ce-ba81-f2b37242e748', '73caa1d9-455a-43ce-ba81-f2b37242e748', '{"sub": "73caa1d9-455a-43ce-ba81-f2b37242e748", "email": "evan.m.eeks@gmail.com", "last_name": "Meeks", "first_name": "Evan", "email_verified": true, "phone_verified": false}', 'email', '2026-01-11 04:02:57.828522+00', '2026-01-11 04:02:57.82857+00', '2026-01-11 04:02:57.82857+00', 'aa106de9-604a-430a-a86a-c40dd790fe95'),
	('2ceae342-cc8c-46c4-a6fd-b625f4471f8a', '2ceae342-cc8c-46c4-a6fd-b625f4471f8a', '{"sub": "2ceae342-cc8c-46c4-a6fd-b625f4471f8a", "email": "evan.m.e+eks@gmail.com", "last_name": "Deeks", "first_name": "Evan", "email_verified": false, "phone_verified": false}', 'email', '2026-01-11 04:07:23.436858+00', '2026-01-11 04:07:23.436915+00', '2026-01-11 04:07:23.436915+00', '7db36694-0cdf-4ab2-ab20-d96c9783d422'),
	('8af556c0-d504-4f0d-99b5-aadfbe9a7107', '8af556c0-d504-4f0d-99b5-aadfbe9a7107', '{"sub": "8af556c0-d504-4f0d-99b5-aadfbe9a7107", "email": "hell.o@dinnafind.com", "email_verified": false, "phone_verified": false}', 'email', '2026-01-11 04:19:38.288694+00', '2026-01-11 04:19:38.288749+00', '2026-01-11 04:19:38.288749+00', '8630af6e-6b87-4ef3-b8b5-2d51071d8481'),
	('29df7fd8-624c-4103-bc83-8c7d6e85c0e0', '29df7fd8-624c-4103-bc83-8c7d6e85c0e0', '{"sub": "29df7fd8-624c-4103-bc83-8c7d6e85c0e0", "email": "e.van.mee.k.s@gmail.com", "last_name": "CCC", "first_name": "D", "email_verified": false, "phone_verified": false}', 'email', '2026-01-11 04:54:03.705387+00', '2026-01-11 04:54:03.705439+00', '2026-01-11 04:54:03.705439+00', '6ae0d683-69e4-449d-8062-f2c937c27821'),
	('286f27d8-00a1-43c5-a855-0f8fe153c423', '286f27d8-00a1-43c5-a855-0f8fe153c423', '{"sub": "286f27d8-00a1-43c5-a855-0f8fe153c423", "email": "ed209.m+@gmail.com", "email_verified": true, "phone_verified": false}', 'email', '2026-01-11 04:48:08.909666+00', '2026-01-11 04:48:08.909719+00', '2026-01-11 04:48:08.909719+00', 'cd7507c2-6ec8-4866-965e-7e7b15f6bba4'),
	('4f308a61-8fde-4783-b1a6-4f1712061da5', '4f308a61-8fde-4783-b1a6-4f1712061da5', '{"sub": "4f308a61-8fde-4783-b1a6-4f1712061da5", "email": "fadeto.bass@gmail.com", "last_name": "Dee", "first_name": "X", "email_verified": true, "phone_verified": false}', 'email', '2026-01-15 03:55:36.488215+00', '2026-01-15 03:55:36.488275+00', '2026-01-15 03:55:36.488275+00', 'f7da7379-29af-4f28-80c9-71919c9ee4eb'),
	('108842097930565120749', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', '{"iss": "https://accounts.google.com", "sub": "108842097930565120749", "name": "Evan Meeks", "email": "evan.meeks@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIUEF_Zz2UhkT0nXwNBMTRd8EmHK6qWv5h5CxrRbQ61j91unVHmAg=s96-c", "full_name": "Evan Meeks", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIUEF_Zz2UhkT0nXwNBMTRd8EmHK6qWv5h5CxrRbQ61j91unVHmAg=s96-c", "provider_id": "108842097930565120749", "email_verified": true, "phone_verified": false}', 'google', '2026-01-09 11:33:04.071852+00', '2026-01-09 11:33:04.07191+00', '2026-01-23 08:43:42.916348+00', '47b429c1-e700-4ac5-b5ba-1db30c3170a8'),
	('9a5e5ad6-f9be-465a-a27f-a6f5a6679bfa', '9a5e5ad6-f9be-465a-a27f-a6f5a6679bfa', '{"sub": "9a5e5ad6-f9be-465a-a27f-a6f5a6679bfa", "email": "appreview@dinnafind.com", "email_verified": false, "phone_verified": false}', 'email', '2026-01-28 06:03:15.933551+00', '2026-01-28 06:03:15.933625+00', '2026-01-28 06:03:15.933625+00', 'c5deaadc-201f-4ca3-bf14-cd15b4b0a3ac'),
	('104496322802490062407', '132fdb5d-3a06-406c-a87b-570b56028a4a', '{"iss": "https://accounts.google.com", "sub": "104496322802490062407", "name": "Clark Kent", "email": "ed209m@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIQXVdnrP_aB6yryjxn9OuNrhiFy4ZBClkbwlgtWQos14s7LZU=s96-c", "full_name": "Clark Kent", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIQXVdnrP_aB6yryjxn9OuNrhiFy4ZBClkbwlgtWQos14s7LZU=s96-c", "provider_id": "104496322802490062407", "email_verified": true, "phone_verified": false}', 'google', '2026-01-09 12:44:20.112394+00', '2026-01-09 12:44:20.112444+00', '2026-01-24 04:35:23.883722+00', '94b98ed4-3013-490a-83f0-00cb55dce21b');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('61ecfb13-45f3-4270-8917-15e96078c8f2', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', '2026-01-23 08:43:42.926288+00', '2026-01-23 08:43:42.926288+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '216.24.210.197', NULL, NULL, NULL, NULL, NULL),
	('28e3f57d-f588-4931-88b1-21ab9c382787', '73caa1d9-455a-43ce-ba81-f2b37242e748', '2026-01-11 04:03:10.234397+00', '2026-01-11 04:03:10.234397+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '173.239.218.109', NULL, NULL, NULL, NULL, NULL),
	('9d28435d-210e-4fd7-82de-1c9b2107dc3f', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-24 04:35:23.91197+00', '2026-01-24 11:40:07.104288+00', NULL, 'aal1', NULL, '2026-01-24 11:40:07.10282', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '70.251.185.22', NULL, NULL, NULL, NULL, NULL),
	('430a3275-57d3-4a70-9fbe-927bd025cef6', 'a5734ec1-210b-4ee0-92f1-d0a99a280713', '2026-01-10 17:15:39.190675+00', '2026-01-10 17:15:39.190675+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '70.251.185.22', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('28e3f57d-f588-4931-88b1-21ab9c382787', '2026-01-11 04:03:10.254633+00', '2026-01-11 04:03:10.254633+00', 'otp', '0cbb9501-75b8-42cb-8509-e7bb17f2bf0c'),
	('61ecfb13-45f3-4270-8917-15e96078c8f2', '2026-01-23 08:43:42.943695+00', '2026-01-23 08:43:42.943695+00', 'oauth', 'e85dda9f-96e1-49a0-924b-0e4646731044'),
	('9d28435d-210e-4fd7-82de-1c9b2107dc3f', '2026-01-24 04:35:23.961592+00', '2026-01-24 04:35:23.961592+00', 'oauth', '1a57f950-0efc-4f8a-a628-77c728c02ab7'),
	('430a3275-57d3-4a70-9fbe-927bd025cef6', '2026-01-10 17:15:39.237939+00', '2026-01-10 17:15:39.237939+00', 'oauth', 'e96e7479-788d-48da-9674-9fe1ab5e9184');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."one_time_tokens" ("id", "user_id", "token_type", "token_hash", "relates_to", "created_at", "updated_at") VALUES
	('9608a0a6-49c0-4116-ad91-ef057a9a61ba', '2bcf4386-383c-4fdd-8c4b-311bc6a85a77', 'confirmation_token', '43f7e680fbc3bae0758f346a935436fcf6dd5e8f886fac2a5579747e', 'fade.to.bass@gmail.com', '2026-01-10 18:51:56.900357', '2026-01-10 18:51:56.900357'),
	('d97d2427-a95a-431b-832c-77d6e054d7e4', '15a0e973-4b17-4d14-aef4-3ee1f768ba44', 'confirmation_token', '8462751e4e1c566bd6e736f7f2030d011d82dd85fd386eb62c85eef3', 'hello@dinnafind.com', '2026-01-10 18:57:50.527124', '2026-01-10 18:57:50.527124'),
	('80b8753b-486b-4406-84e3-a8e0a3f3c250', '2ceae342-cc8c-46c4-a6fd-b625f4471f8a', 'confirmation_token', 'd7625f5b7dacfa67d965ce8cf8405c702e8422e4c6096c44f1fce474', 'evan.m.e+eks@gmail.com', '2026-01-11 04:07:23.58749', '2026-01-11 04:07:23.58749'),
	('8d7c7db2-1597-4315-b65a-53b4698639e9', '8af556c0-d504-4f0d-99b5-aadfbe9a7107', 'confirmation_token', 'd5076f3b1b0b3cb7ee807bb74d55be22d757d438e851c46375fe2633', 'hell.o@dinnafind.com', '2026-01-11 04:19:38.491109', '2026-01-11 04:19:38.491109'),
	('df0bd108-61c4-49dc-b078-523b40eb8b74', '29df7fd8-624c-4103-bc83-8c7d6e85c0e0', 'confirmation_token', '799cc607ba84b5284bf136ef4e4acbb84bbad18e588d4293326e905c', 'e.van.mee.k.s@gmail.com', '2026-01-11 04:54:03.80979', '2026-01-11 04:54:03.80979');


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 100, 'w2knamdto4js', '73caa1d9-455a-43ce-ba81-f2b37242e748', false, '2026-01-11 04:03:10.243165+00', '2026-01-11 04:03:10.243165+00', NULL, '28e3f57d-f588-4931-88b1-21ab9c382787'),
	('00000000-0000-0000-0000-000000000000', 367, 'f7c275ns7pwy', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', false, '2026-01-23 08:43:42.93303+00', '2026-01-23 08:43:42.93303+00', NULL, '61ecfb13-45f3-4270-8917-15e96078c8f2'),
	('00000000-0000-0000-0000-000000000000', 73, 'tka3smaia4il', 'a5734ec1-210b-4ee0-92f1-d0a99a280713', false, '2026-01-10 17:15:39.208735+00', '2026-01-10 17:15:39.208735+00', NULL, '430a3275-57d3-4a70-9fbe-927bd025cef6'),
	('00000000-0000-0000-0000-000000000000', 368, 'e7y362utscbx', '132fdb5d-3a06-406c-a87b-570b56028a4a', true, '2026-01-24 04:35:23.935686+00', '2026-01-24 06:13:12.596448+00', NULL, '9d28435d-210e-4fd7-82de-1c9b2107dc3f'),
	('00000000-0000-0000-0000-000000000000', 369, 'w2glrpvbcqh3', '132fdb5d-3a06-406c-a87b-570b56028a4a', true, '2026-01-24 06:13:12.617471+00', '2026-01-24 07:16:21.898492+00', 'e7y362utscbx', '9d28435d-210e-4fd7-82de-1c9b2107dc3f'),
	('00000000-0000-0000-0000-000000000000', 370, 'jrirhrksctgs', '132fdb5d-3a06-406c-a87b-570b56028a4a', true, '2026-01-24 07:16:21.923738+00', '2026-01-24 09:42:03.276664+00', 'w2glrpvbcqh3', '9d28435d-210e-4fd7-82de-1c9b2107dc3f'),
	('00000000-0000-0000-0000-000000000000', 371, '7bgxa7yhk4gg', '132fdb5d-3a06-406c-a87b-570b56028a4a', true, '2026-01-24 09:42:03.308373+00', '2026-01-24 11:40:07.052434+00', 'jrirhrksctgs', '9d28435d-210e-4fd7-82de-1c9b2107dc3f'),
	('00000000-0000-0000-0000-000000000000', 372, 'sx5gewoiv44w', '132fdb5d-3a06-406c-a87b-570b56028a4a', false, '2026-01-24 11:40:07.071983+00', '2026-01-24 11:40:07.071983+00', '7bgxa7yhk4gg', '9d28435d-210e-4fd7-82de-1c9b2107dc3f');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: context_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."context_types" ("slug", "label", "description", "is_active", "sort_order", "created_at", "updated_at") VALUES
	('academic_symposium', 'Academic Symposium', 'Curated research or academic convenings.', true, 10, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('scientific_paper', 'Scientific Paper', 'Peer-reviewed or preprint technical publication.', true, 20, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('media_broadcast', 'Media Broadcast', 'Televised/radio/stream broadcast or feature interview.', true, 30, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('public_statement', 'Public Statement', 'On-record prepared remarks or declaration.', true, 40, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('documentary_film', 'Documentary Film', 'Documentary-format film release.', true, 50, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('nonfiction_film', 'Nonfiction Film', 'Nonfiction film outside traditional documentary form.', true, 60, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('fiction_film', 'Fiction Film', 'Scripted/fictionalized film with disclosure content.', true, 70, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('podcast_episode', 'Podcast Episode', 'Audio/video podcast episode.', true, 80, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('press_conference', 'Press Conference', 'Live or recorded press conference/gaggle.', true, 90, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('book_publication', 'Book Publication', 'Published book or e-book release.', true, 100, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('government_report', 'Government Report', 'Official governmental/agency report.', true, 110, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('classified_proceeding', 'Classified Proceeding', 'SCIF, closed-door, or compartmentalized session.', true, 120, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('declassified_document', 'Declassified Document', 'Formerly classified material now released.', true, 130, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('congressional_hearing', 'Congressional Hearing', 'Formal congressional hearing or briefing.', true, 140, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('press_release', 'Press Release', 'Formal press release distribution.', true, 150, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('international_agreement', 'International Agreement', 'Treaty/MoU or joint declaration.', true, 160, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('international_statement', 'International Statement', 'Official international/foreign government statement.', true, 170, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('legal_filing', 'Legal Filing', 'Court filing, motion, or pleading.', true, 180, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('witness_testimony', 'Witness Testimony', 'Sworn testimony or deposition equivalent.', true, 190, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('whistleblower_account', 'Whistleblower Account', 'On-record or protected disclosure by an insider.', true, 200, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('legal_deposition', 'Legal Deposition', 'Recorded deposition or affidavit.', true, 210, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('visual_evidence', 'Visual Evidence', 'Photo/video/audio artifact offered as evidence.', true, 220, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('forensic_claim', 'Forensic Claim', 'Forensic examination or evidentiary claim.', true, 230, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('material_sample', 'Material Sample', 'Physical sample release or chain-of-custody claim.', true, 240, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('archaeological_find', 'Archaeological Find', 'Archaeological or historical material discovery.', true, 250, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('viral_narrative', 'Viral Narrative', 'Rapidly spreading narrative or rumor chain.', true, 260, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('social_media', 'Social Media', 'Platform-first social post/space/thread.', true, 270, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('fourchan_leak', '4chan Leak', 'Leak originating on 4chan.', true, 280, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('forum_leak', 'Forum Leak', 'Leak originating on forums outside 4chan.', true, 290, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('anon_hack_and_release', 'Anon Hack and Release', 'Anonymous hack-and-dump release.', true, 300, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('patent_application', 'Patent Application', 'Patent or provisional application.', true, 310, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('internal', 'Internal', 'Internal-only circulation.', false, 400, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('operational', 'Operational', 'Operational context.', false, 410, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('media_interview', 'Media Interview', 'Interview-format media appearance.', false, 420, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('document_release', 'Document Release', 'General document release.', false, 430, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('unspecified', 'Unspecified / Other', 'Unspecified or legacy context.', false, 999, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00');


--
-- Data for Name: metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."metrics" ("id", "name", "category", "question", "criteria", "min_val", "max_val", "community_score", "created_at", "updated_at", "low_description", "high_description", "scoring_criteria") VALUES
	(1, 'Specificity of Claims', 'CORE', 'Are concrete entities, documents, programs, locations, or mechanisms named?', 'No contradictions to Full logical coherence', 1, 5, 4.2, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Pure abstraction, no specifics', 'Names entities and explains relevance', '[{"label": "Pure abstraction", "score": 1, "description": "No specific details, vague generalities only"}, {"label": "Minimal specificity", "score": 2, "description": "Few concrete details, mostly abstract claims"}, {"label": "Mixed", "score": 3, "description": "Some verifiable details mixed with abstractions"}, {"label": "Largely specific", "score": 4, "description": "Multiple concrete, verifiable details provided"}, {"label": "Names verifiable entities", "score": 5, "description": "Highly specific names, dates, locations, documents"}]'),
	(2, 'Causal Direction', 'CORE', 'Does the disclosure explain how the information advances disclosure?', 'Single source to Multiple independent confirmations', 1, 5, 3.8, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'No causal link', 'Clear cause → effect → outcome chain', '[{"label": "No link", "score": 1, "description": "Circular reasoning, no forward momentum"}, {"label": "Weak link", "score": 2, "description": "Unclear or tenuous causal connections"}, {"label": "Mixed / Partial Evidence", "score": 3, "description": "Some logical progression, some gaps"}, {"label": "Strong causation", "score": 4, "description": "Clear logical flow with few gaps"}, {"label": "Clear cause→effect chain", "score": 5, "description": "Explicit, verifiable causal mechanism explained"}]'),
	(3, 'Actionability', 'CORE', 'Can investigators, journalists, or institutions act on this?', 'No relevant background to Direct program involvement', 1, 5, 4.5, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'No possible follow-up', 'Clear next steps (FOIA, hearings)', '[{"label": "No follow-up", "score": 1, "description": "Dead end, no actionable leads"}, {"label": "Minimal action", "score": 2, "description": "Very limited follow-up possibilities"}, {"label": "Moderate actionability", "score": 3, "description": "Some concrete next steps possible"}, {"label": "Highly actionable", "score": 4, "description": "Multiple clear investigative paths"}, {"label": "Clear FOIA/hearing targets", "score": 5, "description": "Specific, immediately actionable intelligence"}]'),
	(4, 'Information Novelty', 'CORE', 'Is this meaningfully new intelligence?', 'Fourth-hand to Direct witness/participant', 1, 5, 3.2, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Recycled lore / rebranded history', 'Previously undisclosed / new evidence', '[{"label": "Recycled lore", "score": 1, "description": "Rehashed claims, nothing new"}, {"label": "Minor variation", "score": 2, "description": "Slight twist on existing narratives"}, {"label": "Some novelty", "score": 3, "description": "Mix of known and new information"}, {"label": "Largely novel", "score": 4, "description": "Substantial new insights or connections"}, {"label": "Previously undisclosed info", "score": 5, "description": "Genuinely new, independently verifiable claims"}]'),
	(5, 'Attribution Integrity', 'CORE', 'Are sources, origins, and prior work properly acknowledged?', 'No documentation to Official classified documents', 1, 5, 4.0, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Laundered ideas', 'Clear lineage of ideas', '[{"label": "Laundered ideas", "score": 1, "description": "No attribution, plagiarized claims"}, {"label": "Poor attribution", "score": 2, "description": "Vague or incomplete source citations"}, {"label": "Mixed attribution", "score": 3, "description": "Some sources cited, others missing"}, {"label": "Good attribution", "score": 4, "description": "Most sources properly acknowledged"}, {"label": "Clear lineage", "score": 5, "description": "Transparent, complete source attribution"}]'),
	(13, 'Information Density', 'IMPACT', 'Signal-to-noise ratio?', 'Minor footnote to Historical turning point', 1, 5, 3.6, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Long-form vagueness', 'High-density, low-fluff', NULL),
	(6, 'Risk Assumed', 'INTEGRITY', 'Does the disclosure impose real cost or risk on the speaker?', 'Vague decades to Exact dates and times', 1, 5, 4.7, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Zero risk, monetized', 'Legal/Professional risk', '[{"label": "Monetize/Safe", "score": 1, "description": "No risk, purely financial gain"}, {"label": "Low risk", "score": 2, "description": "Minimal personal or professional exposure"}, {"label": "Moderate risk", "score": 3, "description": "Some professional or reputational stakes"}, {"label": "Significant risk", "score": 4, "description": "Substantial professional/legal exposure"}, {"label": "Skipped/Personal risk", "score": 5, "description": "Serious legal, professional, or safety risk"}]'),
	(7, 'Resistance to Myth', 'INTEGRITY', 'Is the information grounded, or mythologized?', 'Unknown location to Precise coordinates', 1, 5, 2.9, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Archetypal, savior/villain framing', 'Clinical, procedural, non-mythic', '[{"label": "Archetypal/Savian", "score": 1, "description": "Mythological framing, no grounding"}, {"label": "Heavily mythologized", "score": 2, "description": "Mostly narrative-driven, little substance"}, {"label": "Mixed grounding", "score": 3, "description": "Some facts, some mythological elements"}, {"label": "Mostly grounded", "score": 4, "description": "Evidence-based with minor mythic elements"}, {"label": "Clinical/Procedural", "score": 5, "description": "Completely grounded in verifiable facts"}]'),
	(8, 'Institutional Targeting', 'INTEGRITY', 'Does it challenge real power structures?', 'Vague descriptions to Detailed technical specifications', 1, 5, 3.5, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Targets abstractions', 'Names accountable offices/agencies', '[{"label": "Abstract \"system\"", "score": 1, "description": "Vague institutional blame, no specifics"}, {"label": "General institutions", "score": 2, "description": "Names organizations but not individuals"}, {"label": "Mixed accountability", "score": 3, "description": "Some specific targets, some abstract"}, {"label": "Specific entities", "score": 4, "description": "Names departments, programs, or roles"}, {"label": "Names specific offices", "score": 5, "description": "Directly challenges specific power holders"}]'),
	(9, 'Timing Coherence', 'INTEGRITY', 'Does timing serve truth, not hype cycles?', 'No verifiable elements to Fully independently verifiable', 1, 5, 3.1, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Synchronized with media launches', 'Disclosure-first timing', '[{"label": "Media sync", "score": 1, "description": "Perfectly timed for publicity, suspicious"}, {"label": "Opportunistic", "score": 2, "description": "Timing suggests strategic media play"}, {"label": "Neutral timing", "score": 3, "description": "No clear pattern either way"}, {"label": "Authentic timing", "score": 4, "description": "Timing aligns with genuine circumstances"}, {"label": "Disclosure-first", "score": 5, "description": "Truth-driven timing, ignores media cycles"}]'),
	(10, 'Intelligence Discipline', 'INTEGRITY', 'Is operational literacy demonstrated?', 'Self-serving to Significant personal/professional risk', 1, 5, 4.1, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'No understanding of ops', 'Demonstrates tradecraft literacy', '[{"label": "Amateur", "score": 1, "description": "No operational understanding, superficial"}, {"label": "Basic knowledge", "score": 2, "description": "Limited operational awareness"}, {"label": "Moderate literacy", "score": 3, "description": "Decent operational understanding"}, {"label": "Strong tradecraft", "score": 4, "description": "Clear operational expertise demonstrated"}, {"label": "Deep tradecraft literacy", "score": 5, "description": "Exceptional operational and analytical rigor"}]'),
	(11, 'Contradiction Resolution', 'IMPACT', 'Are inconsistencies addressed directly?', 'Minimal impact to Critical security concerns', 1, 5, 2.5, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Ignores past contradictions', 'Explicitly reconciles conflict', NULL),
	(12, 'Incentive Transparency', 'IMPACT', 'Are financial interests disclosed or minimized?', 'Conventional science to Paradigm-shifting', 1, 5, 3.9, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Hidden monetization', 'Clear separation from profit', NULL),
	(14, 'External Verifiability', 'IMPACT', 'Can third parties validate elements independently?', 'Limited interest to Essential public knowledge', 1, 5, 4.3, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'No verification path', 'Clear verification vectors', NULL),
	(15, 'Vector Direction', 'IMPACT', 'Does this push toward resolution or perpetual theater?', 'Ignored to Major policy changes', 1, 5, 3.4, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Endless tease', 'Collapses ambiguity', NULL),
	(16, 'Network Dependence', 'IMPACT', 'Is credibility borrowed from closed ecosystems?', 'No follow-up to Congressional hearings', 1, 5, 4.0, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Circular validation', 'Independent of influencer networks', NULL),
	(17, 'History Accuracy', 'IMPACT', 'Is intelligence history handled competently?', 'No coverage to Intensive investigative journalism', 1, 5, 3.7, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Naïve/Mythic history', 'Accurate use of precedents', NULL),
	(18, 'Pressure Resilience', 'IMPACT', 'Does the claim survive adversarial questioning?', 'No expert review to Comprehensive peer review', 1, 5, 4.2, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Collapses under scrutiny', 'Strengthens under pressure', NULL),
	(19, 'Strategic Coherence', 'IMPACT', 'Is there an identifiable long-term strategy?', 'No protections to Full whistleblower protections', 1, 5, 3.0, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Chaotic/Opportunistic', 'Coherent long-range arc', NULL),
	(20, 'Net Disclosure Value', 'IMPACT', 'Does this reduce uncertainty or increase it?', 'No current access to Active ongoing access', 1, 5, 3.8, '2026-01-09 11:46:39.154045+00', '2026-01-19 23:18:46.364005+00', 'Increases confusion', 'Meaningfully clarifies terrain', NULL);


--
-- Data for Name: origin_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."origin_types" ("slug", "label", "abbreviation", "description", "is_active", "sort_order", "created_at", "updated_at") VALUES
	('ic_national', 'US Intelligence Community', 'IC', 'ODNI, CIA, NSA, NGA, NRO, DIA products or briefings.', true, 10, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('dod_joint', 'DoD Joint/OSD', 'DOD', 'Joint Staff, OSD, combatant commands, or cross-service task forces.', true, 20, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('dod_usaf_ussf', 'USAF/USSF', 'USAF', 'Air and Space Force programs, labs, or operational channels.', true, 21, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('dod_usn', 'US Navy', 'USN', 'Navy platforms, ONR, NAVAIR, NAVSEA, or fleet channels.', true, 22, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('dod_usa', 'US Army', 'USA', 'Army commands, labs, or service-owned programs.', true, 23, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('nasa_civil_space', 'NASA', 'NASA', 'Civil space agency missions, payloads, or directorates.', true, 30, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('federal_civil_agency', 'Federal Civil Agency', 'CIV', 'Non-defense agencies (NOAA, FAA, DOE, DHS, etc.).', true, 35, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('legislative_branch', 'Congressional', 'CONG', 'Committees, hearings, SCIF briefings, GAO/CRS reporting.', true, 40, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('law_enforcement', 'Law Enforcement', 'LE', 'FBI, NCIS, OSI, DHS/HSI, or other investigative arms.', true, 45, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('academic_institution', 'Academic', 'ACAD', 'Universities, research institutes, or symposium hosts.', true, 50, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('private_sector_corporate', 'Private Sector / Contractor', 'PRIV', 'Companies, defense primes, aerospace, data vendors.', true, 60, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('media_organization', 'Media Organization', 'MEDIA', 'Newsrooms or broadcasters acting as originators.', true, 70, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('ngo_thinktank', 'NGO / Think Tank', 'NGO', 'Nonprofits, policy shops, or advocacy organizations.', true, 80, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('international_gov', 'International Gov/Defense', 'INTL', 'Non-US government or defense entities.', true, 90, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('whistleblower_or_leak', 'Whistleblower / Leak', 'LEAK', 'Unauthorized disclosures from insiders or anonymous sources.', true, 95, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('independent_researcher', 'Independent Researcher', 'IND', 'Unaffiliated individuals releasing primary material.', true, 96, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00'),
	('unspecified', 'Unspecified / Other', 'UNK', 'Unspecified or legacy origin entries.', true, 99, '2026-01-20 22:49:18.458721+00', '2026-01-20 22:49:18.458721+00');


--
-- Data for Name: rfc_proposals; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."rfc_proposals" ("id", "user_id", "metric_id", "proposal_type", "proposed_name", "proposed_question", "proposed_min_criteria", "proposed_max_criteria", "proposed_category", "rich_entries", "rationale", "status", "reviewed_by", "reviewed_at", "review_notes", "created_at", "updated_at") VALUES
	('42430fab-0a97-4096-8ecd-e4c705711f98', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 1, 'modify_existing', 'Specificity of Claims', 'How specific are the claims?cccc', 'Vague or abstract', 'Concrete and verifiable', 'CORE', '', '**Type: RFC (Request for Comment)**

', 'pending', NULL, NULL, NULL, '2026-01-11 00:16:02.525518+00', '2026-01-11 00:16:02.525518+00'),
	('990b2ffc-77c5-4b31-b878-cf7ac863c083', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 10, 'modify_existing', 'Intel. Disciplineddd', 'Does it follow intelligence discipline?', 'Lacks discipline', 'Professional discipline', 'INTEGRITY', '', '**Type: RFC (Request for Comment)**

', 'pending', NULL, NULL, NULL, '2026-01-11 00:17:17.839718+00', '2026-01-11 00:17:17.839718+00'),
	('ef559660-f88c-4b7b-8488-31eb5cdc8a9c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', NULL, 'new_metric', 'Actionability', 'Can the information be acted upon?', 'No actionable steps', 'Clear action items', 'CORE', '', 'sdfsdfsd', 'pending', NULL, NULL, NULL, '2026-01-11 02:17:33.843421+00', '2026-01-11 02:17:33.843421+00'),
	('199eea06-0c65-41a5-abf6-30d835dba280', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 17, 'modify_existing', 'Historical Context', 'Is historical context provided?', 'No context', 'Rich context', 'IMPACT', 'dfdsfds', '**Type: RFC (Request for Comment)**

dsdsfsdfsdsdfds', 'pending', NULL, NULL, NULL, '2026-01-11 03:05:41.051663+00', '2026-01-11 03:05:41.051663+00'),
	('b64289ae-7bc7-45b8-bb42-ab79ba1b444e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 17, 'modify_existing', 'Historical Context', 'Is historical context provided?', 'No context', 'Rich context', 'IMPACT', 'dfdsfds', '**Type: RFC (Request for Comment)**

dsdsfsdfsdsdfds', 'pending', NULL, NULL, NULL, '2026-01-11 03:05:41.263362+00', '2026-01-11 03:05:41.263362+00'),
	('b854a139-e5bd-4084-873b-3dda06bea715', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 3, 'modify_existing', 'Actionability', 'Can the information be acted upon?', 'No actionable steps', 'Clear action items', 'CORE', 'sdfsd', '**Type: RFC (Request for Comment)**

sdfsfdsds', 'pending', NULL, NULL, NULL, '2026-01-11 03:09:26.189059+00', '2026-01-11 03:09:26.189059+00'),
	('bea96ad6-fa3d-4806-9085-37e664fc741c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', NULL, 'new_metric', 'Attribution Integrities', 'Are sources properly integreties', 'No integreites', 'Full source integegrities', 'CORE', '', 'sadfasdfed', 'pending', NULL, NULL, NULL, '2026-01-11 13:38:48.305732+00', '2026-01-11 13:38:48.305732+00'),
	('7fcb4f7c-be9f-42ac-a8bc-7897bfb6422e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', NULL, 'new_metric', 'ccv', 'Does it float?', 'Float', 'SInky', 'CORE', '', 'Good and floaty', 'pending', NULL, NULL, NULL, '2026-01-11 13:47:42.047038+00', '2026-01-11 13:47:42.047038+00'),
	('860c0850-87e2-441d-b648-cff80e28e8f1', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', NULL, 'new_metric', 'METRIC NAME', 'Does it smell?', 'Stink', 'Aroma', 'CORE', '', 'R a tional anle', 'pending', NULL, NULL, NULL, '2026-01-11 13:52:49.701829+00', '2026-01-11 13:52:49.701829+00'),
	('c9f2a5ba-0b80-4d9f-912d-e79889afaa20', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', NULL, 'new_metric', 'Information Novelty', 'How novel is the information?', 'Widely known', 'Previously undisclosed', 'CORE', '', 'Rationale', 'pending', NULL, NULL, NULL, '2026-01-15 03:20:17.821238+00', '2026-01-15 03:20:17.821238+00');


--
-- Data for Name: targets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."targets" ("id", "name", "case_id", "origin", "context", "verified", "description", "created_at", "updated_at", "source_url", "claim_date", "primary_source", "tags") VALUES
	('nimitz-2004', 'Nimitz_Encounter_2004', 'NCI-9.2-XREF-QDD', 'dod_usn', 'operational', true, 'USS Nimitz carrier strike group UAP encounter', '2026-01-20 19:17:19.683291+00', '2026-01-20 22:49:19.269393+00', NULL, '2004-11-14', 'US Navy', NULL),
	('sol-foundation-2023', 'Sol Foundation Symposium 2023', 'QDD-ACAD-ACADEMIC_SYMPOSIUM-0010', 'academic_institution', 'academic_symposium', true, 'Academic symposium on UAP disclosure hosted by Sol Foundation', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2023-11-01', 'Sol Foundation', NULL),
	('grusch-newsnation-2023', 'David Grusch - NewsNation Interview', 'QDD-PRIV-MEDIA_BROADCAST-0011', 'private_sector_corporate', 'media_broadcast', true, 'NewsNation interview with David Grusch discussing UAP disclosure', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2023-06-11', 'NewsNation', NULL),
	('congressional-scif-jan-2024', 'Congressional SCIF Briefing (Jan)', 'QDD-CONG-CLASSIFIED_PROCEEDING-0012', 'legislative_branch', 'classified_proceeding', true, 'Classified briefing to Congressional members regarding UAP', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2024-01-15', 'US Congress', NULL),
	('jellyfish-uap-jan-2024', 'Jellyfish UAP Video Release', 'QDD-IND-VISUAL_EVIDENCE-0013', 'independent_researcher', 'visual_evidence', false, 'Release of alleged UAP video footage showing jellyfish-like object', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2024-01-10', 'Jeremy Corbell', NULL),
	('nazca-mummies-2023', 'Nazca Mummies (Initial Release)', 'QDD-IND-FORENSIC_CLAIM-0014', 'independent_researcher', 'forensic_claim', false, 'Initial public presentation of alleged non-human mummies from Peru', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2023-09-13', 'Jaime Maussan', NULL),
	('miami-mall-jan-2024', 'Miami Mall Incident (Social Media)', 'QDD-UNK-VIRAL_NARRATIVE-0015', 'unspecified', 'viral_narrative', false, 'Social media viral narrative regarding alleged incident at Miami mall', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2024-01-03', 'Social Media', NULL),
	('aaro-report-vol1-2024', 'AARO Historical Report Vol 1', 'QDD-DOD-GOVERNMENT_REPORT-0016', 'dod_joint', 'government_report', true, 'All-domain Anomaly Resolution Office historical report volume 1', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2024-02-29', 'AARO/DoD', NULL),
	('ilyumzhinov-interview-2023', 'Kirsan Ilyumzhinov Interview', 'QDD-MEDIA-WITNESS_TESTIMONY-0017', 'media_organization', 'witness_testimony', false, 'Interview with former FIDE president regarding alleged UAP encounter', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2023-10-15', 'Various Media', NULL),
	('sheehan-disclosure-2023', 'Danny Sheehan - Disclosure Project', 'QDD-NGO-PUBLIC_STATEMENT-0018', 'ngo_thinktank', 'public_statement', false, 'Public statement and disclosure initiative from attorney Danny Sheehan', '2026-01-20 19:17:20.760777+00', '2026-01-20 22:49:19.269393+00', NULL, '2023-12-01', 'New Paradigm Institute', NULL),
	('sdfsewerere', 'Grusch_T_2024', 'NCI-8.3-XREF-QDD', 'ic_national', 'congressional_hearing', true, 'David Grusch UAP disclosure testimony before Congress', '2026-01-17 02:17:27.575198+00', '2026-01-20 22:49:19.269393+00', NULL, '2023-07-26', 'Congressional Record', NULL),
	('114141214414', 'Eric Hecker', 'QDD-001-DOD-0007', 'dod_joint', 'congressional_hearing', true, 'Redacted YouTube', '2026-01-17 02:18:15.187558+00', '2026-01-20 22:49:19.269393+00', 'https://deciphering.tv', '2001-01-01', 'Redacted', NULL),
	('wilson-memo-2002', 'Wilson_Memo_2002', 'NCI-7.1-XREF-QDD', 'dod_joint', 'internal', true, 'Eric Davis notes from Admiral Wilson meeting', '2026-01-17 02:14:55.628005+00', '2026-01-20 22:49:19.269393+00', NULL, '2002-10-16', 'Eric Davis Notes', NULL),
	('sdfsdfsdf ', 'Bob Lagar', 'QDD-001-PRIV-0011', 'private_sector_corporate', 'media_interview', true, 'Bob Antigravity Lazar', '2026-01-17 02:17:16.99094+00', '2026-01-20 22:49:19.269393+00', NULL, '1990-01-01', 'George Knapp', NULL),
	('QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 'Varhgina Brazillan ', 'QDD-PRIV-MEDIA_BROADCAST-0031', 'private_sector_corporate', 'media_broadcast', true, 'https://www.youtube.com/watch?v=99hRVeBzTzE', '2026-01-20 22:57:22.956756+00', '2026-01-20 22:57:22.956756+00', 'https://www.youtube.com/watch?v=99hRVeBzTzE', '2026-01-20', 'News Nation', NULL);


--
-- Data for Name: activity_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."activity_log" ("id", "user_id", "activity_type", "target_id", "metric_id", "discussion_id", "rfc_id", "metadata", "description", "created_at") VALUES
	('694d5ac4-1e12-4307-b7fe-34fc8e399c2e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 9, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:12:17.501329+00'),
	('1c6f8722-68b1-40ce-b8ef-6c9ca0dedd5e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:12:18.901263+00'),
	('d2e5f096-ee84-4bd6-b4cf-2ae7afa5a91a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:12:19.062633+00'),
	('a429316b-a7c1-414b-adcb-e0d7227e8d48', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:42:13.551759+00'),
	('9e7178d6-1022-4b27-8cd9-9b2e2ad3ed08', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:15.723644+00'),
	('2e190759-db1a-471c-944e-d2003fe1d9bd', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 20, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.272498+00'),
	('e933adf5-f324-468a-8232-4131326c4948', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 12, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.07099+00'),
	('f670d885-42c9-42b1-aa65-d1fc02627891', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 20, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.950285+00'),
	('3787bd89-211f-4010-86f5-3896d66076f4', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, 1, NULL, '42430fab-0a97-4096-8ecd-e4c705711f98', '{"metric_id": 1, "proposal_type": "modify_existing"}', 'Submitted RFC proposal', '2026-01-11 00:16:02.525518+00'),
	('8f37f0d7-3800-4768-a02e-64c1d55aa3c7', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, 10, NULL, '990b2ffc-77c5-4b31-b878-cf7ac863c083', '{"metric_id": 10, "proposal_type": "modify_existing"}', 'Submitted RFC proposal', '2026-01-11 00:17:17.839718+00'),
	('e296bf8d-f4df-4314-aafa-7a6d28c11dad', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 3, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.015293+00'),
	('4fab8a77-baf4-49c2-9796-a264d02e7eee', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 16, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.125412+00'),
	('8ad4e4e6-ff0e-414e-a5f9-f7781dae6d3d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 10, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.148042+00'),
	('47964616-3ed0-41f3-b07c-311633a5e801', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 4, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.244502+00'),
	('a4e97b00-6004-4624-bd47-f23de043519c', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 7, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.406249+00'),
	('f8d8243a-815f-450f-b9cd-db5b219b8edf', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 2, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.743935+00'),
	('273e6775-09e7-4029-adb3-78efd307dbb7', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, NULL, NULL, 'ef559660-f88c-4b7b-8488-31eb5cdc8a9c', '{"metric_id": null, "proposal_type": "new_metric"}', 'Submitted RFC proposal', '2026-01-11 02:17:33.843421+00'),
	('0cdb95fb-63b5-4564-bfa9-6580abcde73d', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, 17, NULL, '199eea06-0c65-41a5-abf6-30d835dba280', '{"metric_id": 17, "proposal_type": "modify_existing"}', 'Submitted RFC proposal', '2026-01-11 03:05:41.051663+00'),
	('edd64bf1-2729-4a70-a051-38b166609730', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, 17, NULL, 'b64289ae-7bc7-45b8-bb42-ab79ba1b444e', '{"metric_id": 17, "proposal_type": "modify_existing"}', 'Submitted RFC proposal', '2026-01-11 03:05:41.263362+00'),
	('e8b93f04-1a0b-49f2-bc71-aa125ca58584', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, 3, NULL, 'b854a139-e5bd-4084-873b-3dda06bea715', '{"metric_id": 3, "proposal_type": "modify_existing"}', 'Submitted RFC proposal', '2026-01-11 03:09:26.189059+00'),
	('324c6da4-9431-4448-9f2e-c2d396a03127', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:17.095614+00'),
	('53fd4125-5898-47fd-883b-b1bb258482e3', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:19.297866+00'),
	('31c5bebe-0755-4f38-8412-bf505c71c85b', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:07:19.453881+00'),
	('f39566c2-fc3f-49cc-a133-366269389d16', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:23.187057+00'),
	('5d8424d9-f07a-4530-8658-1a35c976b3c7', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:07:23.307722+00'),
	('a9be1560-9f77-448e-8170-1168ca40ec6a', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:24.376048+00'),
	('a9a7c87a-bfce-4549-b2d1-cbad20a731d4', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:25.846702+00'),
	('f351c910-911a-41a6-82bf-151686e24846', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:07:26.445003+00'),
	('74e8bbac-d3aa-474a-a98f-de9e036489ee', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:27.473962+00'),
	('36516d8a-7907-4e89-9e1d-11572dd9d8d8', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:07:27.604018+00'),
	('7c8fc236-80a7-4026-8525-a1293272f3f8', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:07:29.284713+00'),
	('7b8f4f28-8971-463f-a23b-19c96cb867e0', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:12:02.828878+00'),
	('f2e3eb35-e2ce-4295-8e77-5833b1fd35b3', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:12:11.542718+00'),
	('3e58252a-d4d8-4f24-9a8a-4063df46d6da', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:12:11.660714+00'),
	('e36f5fb0-a627-4dae-a23b-c15cc6b03550', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:12:13.338824+00'),
	('9d5837a4-0619-44f5-8d58-b15d9fad0e39', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:12:13.483511+00'),
	('53ee6e71-4dfa-48cf-b17e-d71994b897c4', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:12:16.368946+00'),
	('b8cdbe0d-30a9-41fa-af95-8f50f28d4f2f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:12:16.498133+00'),
	('279ae461-464b-43f6-9c59-cf71679adb21', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:12:17.364177+00'),
	('28c35949-9e42-472a-a1c5-2b360386f099', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 6, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.045511+00'),
	('75344dc3-7a7d-4f1a-a267-ea69a58e382f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 20, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.127535+00'),
	('327e21f3-4a2c-44df-af09-1d55dfbd9c0d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 1, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.147531+00'),
	('5f7cb8a9-ca80-4769-abaf-c1d408b975e2', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 18, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.33651+00'),
	('be046888-fced-4598-9d70-0b50d2975009', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 14, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.411813+00'),
	('e1d2a58f-f401-4d73-a6f3-22ae5aae6c1e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 1, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.718651+00'),
	('57fb8400-1bb4-4553-9e53-668c0601633c', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 7, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.061026+00'),
	('52037326-306f-42cc-9d36-5d36dc74fcda', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 11, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.133262+00'),
	('470c9b32-73a7-4caf-9b79-5843162d6b4b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 18, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.149209+00'),
	('14174f0f-8ae4-4801-a773-2a17a8ac0cb5', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 8, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.339913+00'),
	('962c1222-fd46-467f-adee-6427e3f6f574', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 3, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.399579+00'),
	('a3d0d247-2848-4b9d-9717-bb5621910628', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 6, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.40609+00'),
	('df26ccae-ac84-4736-a625-7e9bf61e8db1', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 3, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.863746+00'),
	('f0ec72f6-a290-41ad-87fb-db361b3e7239', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:28.421639+00'),
	('c04a7727-ce76-4a4c-a746-ac3019bb7e94', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:30.341685+00'),
	('76ff0e08-d2a2-44a3-be6e-b8b8135236d3', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:32.702347+00'),
	('6686d9e3-0ac0-4927-9764-d720d6cd0452', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:35.293787+00'),
	('fb2d3936-6a48-4c29-811d-decf248cdbd0', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:38.288593+00'),
	('ce72679b-bfdd-40d4-8aa0-d3e2481afd29', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:31:41.465498+00'),
	('be38d6b2-ffcb-437a-8dc3-897c3f83bc80', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:31:41.608953+00'),
	('48b6e810-c54a-40b2-9245-f18ee34655f5', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:42.814621+00'),
	('07b21e50-8353-4369-99ad-e20fd390bc0b', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:31:42.953717+00'),
	('a5564cf4-a1fd-4e34-a46e-c37fad806c47', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:44.102133+00'),
	('3e07a10f-31b0-420b-890c-f611339f9363', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:45.52883+00'),
	('14e66e25-602d-4ad0-8178-e0accfd75c9f', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:52:36.743821+00'),
	('454f62a1-00f6-4464-9a82-6e48404e229d', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:26:51.917638+00'),
	('8e8e8e73-607a-498c-928a-43e071ed73ec', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:26:52.998337+00'),
	('2978cf68-5a97-43f4-81fa-371900223561', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:26:53.152308+00'),
	('bf999cca-bf53-43d2-9ab3-92b6717386ce', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "low"}', 'Updated community vote', '2026-01-11 07:26:54.473557+00'),
	('2ec2b3b6-f1b9-48f3-923b-19a640f5efff', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "low"}', 'Updated community vote', '2026-01-11 07:26:54.614407+00'),
	('42697860-42a8-49ed-b775-6bb8c1e911b0', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "low"}', 'Updated community vote', '2026-01-11 07:26:55.125965+00'),
	('5c136252-38e5-4382-b07a-6e6a794dd5d1', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:26:57.745842+00'),
	('945cd756-7ce4-487c-a2f7-06e2e5407726', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:26:57.833921+00'),
	('ec59c516-ddbd-4df6-b4c0-64b23a0b39a6', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 14, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.07429+00'),
	('f6c2e75c-1fef-4c46-aca3-32df8077e5cc', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 12, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.141161+00'),
	('bbb50d4f-492c-41a8-8ec4-ac5be01853fb', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:51:26.023396+00'),
	('1c5c03d3-c71b-4ef3-99ae-dcb965bb91b3', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:38.806731+00'),
	('840ed7b3-815d-4924-b258-4099c2289763', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 5, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.150413+00'),
	('14e33e34-f7d6-4e45-a25b-8e4d53da8eae', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 13, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.164447+00'),
	('b69b10dc-7968-4c0a-a0c2-ac6b530e3fb6', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 2, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.344367+00'),
	('ef2535d7-f99f-44fa-9a14-4253e44d6e3a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 1, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.399847+00'),
	('18ea20a0-eba7-42e3-be72-087e8a13a274', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 17, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.412174+00'),
	('94b319c4-e068-4216-8ef1-534fef4d05f4', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 9, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.803627+00'),
	('8b4268f2-0cd2-444c-be91-c0315e541796', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 4, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.105447+00'),
	('9e3519cd-9824-4dcb-b2af-de3eca9b1587', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 11, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.345016+00'),
	('1722f870-4a9e-4846-856f-fce4225bc279', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:27.268615+00'),
	('240e5d9b-1ff9-413c-8d67-da9fd57d2050', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:51:38.96507+00'),
	('2a4264a2-0882-4230-92a6-f609b4024c29', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 8, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.793752+00'),
	('10fc0e8f-85f2-4a1a-bde5-ff146a0b827e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 19, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.124442+00'),
	('3bbf042a-ec35-4d5a-98c2-20cf8406e42d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:58.960941+00'),
	('785ddd1f-4e48-44e1-865f-1361c0c33dc3', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "high"}', 'Submitted community vote', '2026-01-11 07:51:36.892072+00'),
	('3255fe33-7531-44ea-aba4-7ff22850220f', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:56.123517+00'),
	('66949c8f-ea22-4ffc-8e04-4f07eb175fd5', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 4, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.087953+00'),
	('48fcbdc6-e440-45b4-8f00-cf08048e7e88', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 7, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.157068+00'),
	('ea8f099b-6edf-4d03-b289-a399c461ba89', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 4, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.908111+00'),
	('7c495838-d0cc-491a-bb2c-640f60d3e43b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 08:32:10.835875+00'),
	('bd1ea219-00e6-4180-a839-22458fb4c855', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:26:30.013203+00'),
	('a0e475e5-8415-4fe7-93aa-27e1bc38904e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:26:31.952355+00'),
	('e79961a3-c597-425a-a1dd-428ec495e018', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "low"}', 'Submitted community vote', '2026-01-11 10:28:14.393112+00'),
	('2f4ee674-619b-4f03-b25d-fcf1ab98e504', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:28:52.033919+00'),
	('e9b6e392-07b4-49e3-91b7-9a2155412024', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:28:53.264194+00'),
	('3e011f04-7c07-48e1-b2b5-920ee62bbdd1', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:28:54.388963+00'),
	('0f6a58d2-7a81-4607-8d16-59c8e0cc41c5', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:28:57.79131+00'),
	('7836cd96-3f1a-4f0c-8a40-7763a569f045', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:35:08.39393+00'),
	('f7cba655-c44f-4080-8e48-f6d503598452', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:35:10.597169+00'),
	('04919c1d-ee3b-4711-91ef-6609dfd7e94e', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:35:12.300026+00'),
	('69d30a2c-01b9-46b1-8043-c7835c5e0613', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:41:49.163933+00'),
	('86d8f90c-ea68-4217-9a74-2f6edbf7c7ed', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:13.026306+00'),
	('284f856c-ba94-4160-bacc-77225184ff76', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 15, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.129207+00'),
	('8c0a917f-fe49-4a04-9085-4fe8695ba0d5', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 5, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:58.961757+00'),
	('b865bcbb-69be-43bf-a3bc-0515fdcda80e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 15, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.093011+00'),
	('2cad3ef9-64ce-44bd-8ac9-15d81156dd88', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 5, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.943766+00'),
	('4d212f8c-343e-4a78-b4df-a9d92fee13ce', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:58:30.681015+00'),
	('e63d90a9-864b-4cdb-96bd-8aa18db97138', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:58:30.806409+00'),
	('ef55f4a7-8d08-4f44-842a-1208b9a96a94', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 08:44:12.826914+00'),
	('7448473e-7426-47ca-afdc-e55ffa003f98', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 09:02:56.991022+00'),
	('cb145eb8-df8a-4d90-a6b9-eb20be11778f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 08:52:47.670752+00'),
	('6b134a22-a5c4-4d3d-9e47-971c20b0ef9e', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:31:34.538338+00'),
	('f9328895-570b-4d0c-82b7-6aeb59d1590a', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:31:35.502669+00'),
	('4a95d14e-3306-4e18-8221-3bef9b2323c0', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:31:37.14419+00'),
	('2a5d176c-02b3-48fb-833f-eac89d9c317d', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:31:39.996981+00'),
	('b84a7bc2-f102-4a25-99a9-c613d8bc9534', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:31:49.131584+00'),
	('ae25d7c6-d065-4536-a964-6f458bb4c6b9', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:31:58.132303+00'),
	('dc02be43-ad13-4ab0-8ac1-8e1db01668d7', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:32:02.967301+00'),
	('a3d139e9-1e52-4ec4-82d7-b446a4da1c76', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:32:06.89434+00'),
	('a33de60a-534a-4e72-9c83-d81f5497cf76', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:17.408267+00'),
	('c3593645-dd80-48c0-bab9-79326de00ae6', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 9, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:42:22.983577+00'),
	('eaf19ca9-4d36-4b22-a7ca-b7c362908015', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 9, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.126602+00'),
	('9966042f-4427-44af-9b45-7b57d5aa6aae', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 20, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:58.965606+00'),
	('a717b846-a30c-4d03-85a7-f9e592489de4', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 13, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.092959+00'),
	('28ff5bc0-6c8b-44b9-821a-2dd593eb508d', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:40.811795+00'),
	('31be1c85-d57a-4d6a-a496-69dc182e9824', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:45.0088+00'),
	('b3b30b70-0003-48e7-9512-438c3b82ef96', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:48.421657+00'),
	('eb4b93fd-4340-4b41-944c-692d5b298561', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:43:31.003224+00'),
	('837d7e86-2e13-4265-aeab-4653562f1e71', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:43:38.046368+00'),
	('ab05fb99-c601-4654-89c5-b1a83f652e9a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 10, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.787075+00'),
	('3482df08-2942-426e-9052-ae57b211f43e', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:20.080509+00'),
	('6901b0f8-8007-4041-b9c8-4a9d2b460edf', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:28.305026+00'),
	('8bc5b51d-c787-4ae3-91cc-39c6b53a967f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 2, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.172491+00'),
	('bc67989e-7255-450e-93a1-289536ff6f4f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 16, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:58.964715+00'),
	('e60d1e90-246c-4354-b594-4ddeecd08125', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 14, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.101011+00'),
	('6b342627-f9f0-49bc-98df-065437444ec0', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:43.989648+00'),
	('1d4df900-cbcd-40c2-9209-849c5aeed594', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:47.357312+00'),
	('0fa04962-220d-4951-9efe-b2dc0ae8e3d7', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:52.239804+00'),
	('59b55399-cb61-4a73-af93-9a4c7af03f06', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:43:30.000672+00'),
	('36f40312-db55-4485-95a0-ae2c2cd7e855', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:43:33.31795+00'),
	('ddba6af0-bf0e-4403-97c7-419c22f011b1', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'ilyumzhinov-interview-2023', 7, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:35:09.83626+00'),
	('f29a52e8-30f0-41f8-a9db-bc80336b31e8', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:22.451763+00'),
	('29cee53d-666d-4c3c-9ba9-93938d7bbae4', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 17, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 22:58:18.182214+00'),
	('44eecfd3-261d-4336-85f3-7c46def204f4', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.070027+00'),
	('8ad9f92c-d547-4c63-8ddb-93544fa358e2', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 3, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.116183+00'),
	('bc50a186-089f-45a7-869e-23e2ba31f7ea', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 1, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.754091+00'),
	('265426ea-eac6-4882-926b-c435840b1333', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 3, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.765959+00'),
	('7fd5181c-d006-4ea0-9c43-ddd2ced5479f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 2, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.829987+00'),
	('be664a2b-3513-4df9-b5fd-f1773b49156e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 7, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.877376+00'),
	('7c09c11f-954d-41aa-8624-19f76cf0645f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 9, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.898185+00'),
	('1a69d360-20c4-4920-8cba-f84a7a7c85d8', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 4, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.919823+00'),
	('1c147e8c-94ef-47ae-b5cb-b75d3d1f79d9', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 19, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.924568+00'),
	('7c692eed-69ba-44bb-a19e-53b604cec5cb', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:37.33042+00'),
	('f8eae51a-672e-4552-80bd-100c09bbfada', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:41.872913+00'),
	('1c26ca70-79ee-4317-bb3b-ff30de40f705', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:46.218415+00'),
	('36f1841a-63da-4239-9f77-b823f5142981', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:42:51.295684+00'),
	('2479d695-37cd-4809-98cc-427757b3602c', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 9, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:43:32.191674+00'),
	('7eae23df-deec-414d-8a8b-b25ba7e7b13e', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:04.843018+00'),
	('cd0b0c35-2490-4c23-ad4b-f422204fb277', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:19:05.692096+00'),
	('3de41861-aa1b-411d-aa85-c6d86b6fedb8', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:19:05.856359+00'),
	('409b6512-7cdc-4fae-bfd7-7264ac26f817', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:19:06.172637+00'),
	('5f3dd226-4491-4c13-843a-c104de8b0817', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:08.798312+00'),
	('53410c18-628a-4fca-a1bc-a7384eff8df3', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:09.892446+00'),
	('605de7b7-5f86-4114-a074-efe395ebe5ea', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:11.454031+00'),
	('56afd3b6-3a12-413c-ae5b-35f59bac1358', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:13.269557+00'),
	('a06713cd-99de-4082-b9b4-4796a197cd71', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:13.984443+00'),
	('ad544a58-786c-4e93-966e-7c36ec9fff68', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:15.731525+00'),
	('16a26060-6f62-40bc-9101-89f8252d3fbd', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:17.456961+00'),
	('919c7261-369d-40b7-ada2-11e91ec2c04d', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:18.493368+00'),
	('be88c62b-ae73-4cb9-903d-691a879112a3', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:19.639392+00'),
	('236bff72-f87f-432c-92af-e22f26240213', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 12:20:20.670928+00'),
	('f3f04b2c-c004-4847-92fe-565d44ec5681', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "low"}', 'Submitted community vote', '2026-01-11 13:26:56.293319+00'),
	('91f88e9a-4702-4cad-8812-36b24ab7477f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:26:57.639089+00'),
	('6d790a3d-7343-4aeb-8225-c60b41ef1c6f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:26:58.890999+00'),
	('a93e6e78-cd8f-46d5-b9a3-cabceaabc106', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:27:00.303561+00'),
	('2821308d-315c-4e4c-9b20-a54e40e05cbb', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 19, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.343152+00'),
	('c1f3a7a2-6629-4f36-aa3a-d326773afb61', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 13, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.39978+00'),
	('1401c547-8d08-4dc7-ad13-8ecf82d33242', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, NULL, NULL, 'bea96ad6-fa3d-4806-9085-37e664fc741c', '{"metric_id": null, "proposal_type": "new_metric"}', 'Submitted RFC proposal', '2026-01-11 13:38:48.305732+00'),
	('2593c790-2db7-463a-8565-bb0c43428874', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 6, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.070113+00'),
	('89b9b803-96d4-4762-a012-dfc6f33c89a1', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 10, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.161084+00'),
	('9748356f-bb52-42a9-8f15-31592b94170a', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'rfc_submit', NULL, NULL, NULL, '7fcb4f7c-be9f-42ac-a8bc-7897bfb6422e', '{"metric_id": null, "proposal_type": "new_metric"}', 'Submitted RFC proposal', '2026-01-11 13:47:42.047038+00'),
	('4f07678a-df93-425c-a236-ceb94b05ec4b', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'rfc_submit', NULL, NULL, NULL, '860c0850-87e2-441d-b648-cff80e28e8f1', '{"metric_id": null, "proposal_type": "new_metric"}', 'Submitted RFC proposal', '2026-01-11 13:52:49.701829+00'),
	('dfd3166d-562b-415d-b39a-c2db4c8d27e2', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 13, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.741273+00'),
	('aeb0f8fa-af69-4ede-bcb0-be8a0ef680bf', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 16, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.834971+00'),
	('7e68b5a0-ec43-4889-967f-bb3deed9675a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 12, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.91956+00'),
	('4d277719-d4a6-4120-b63d-2e3f80b6b9f5', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:25:35.838079+00'),
	('8ea9c00d-cd3f-4b9b-b234-ce2e08428f43', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:38.417936+00'),
	('ef2a0a1e-4cd2-46da-8310-a146b0dd23aa', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:39.75013+00'),
	('fa363aac-3d58-4927-ad3f-d4cb563ca5d2', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:41.915378+00'),
	('b71bd64a-19a5-435d-b278-37a414b872e1', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:42.934309+00'),
	('1a9f2ead-ec0c-42df-bc34-a6e63177f53c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:45.403934+00'),
	('01d1fc14-43c8-4898-8f84-3e55a7f9544b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:46.574217+00'),
	('ae04acd6-9e47-40f7-814a-f876c2062fdf', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:48.127568+00'),
	('c0856e1e-0c96-4b51-85b8-b83b1fbe358b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:24:48.490441+00'),
	('6b17bcfc-d808-408d-a041-548fc27c7447', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:49.744079+00'),
	('a6d2a98a-cb2e-412b-a584-a6ff5c0d2f3c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "low"}', 'Submitted community vote', '2026-01-11 13:37:51.766206+00'),
	('63d06d31-5f2f-4c7b-af7a-8376a11e0a2f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:37:52.806103+00'),
	('a525374f-de26-4816-9cee-d70c6312c263', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:43:25.413844+00'),
	('0d4caf7f-c3b6-4efe-997a-7467d1893963', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:43:26.127886+00'),
	('991881fe-0fb0-430b-90df-8fc5a66b8a56', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 14:29:23.64262+00'),
	('da475e81-f4d5-4fc3-8875-74b81fc79b79', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 14:29:42.466109+00'),
	('1af4054d-0007-462c-985c-631bd0c76940', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 14:29:42.798864+00'),
	('968d9506-08f7-40a3-b266-59e98e480220', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 14:29:43.306862+00'),
	('0aa81352-5837-446c-97cf-6eaf9118fd89', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 14:29:43.711329+00'),
	('cc988f40-6377-4e9b-be98-3b1490b0b5be', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:29:44.761707+00'),
	('7bcc08e1-493a-4b93-b6ac-07a87cb2a245', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:29:45.085038+00'),
	('56a6e3dd-48af-4d00-9321-bc68225878ce', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:29:45.989937+00'),
	('a83b1f0c-3cb3-4f2c-8a20-f60605011f0b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 00:46:51.993968+00'),
	('56328dec-e965-4964-ad14-c9df08363b29', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:24:51.001389+00'),
	('1a757b90-b425-4222-a01c-ba0317e32a0c', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:09.989772+00'),
	('3fb2a687-003e-4572-ae89-b12013d4f3ca', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:11.148706+00'),
	('ba8c8504-27be-4e3c-b35a-8f4a9a034340', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:41:11.363968+00'),
	('86a22db3-8103-4065-99be-c02eccd0130a', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:12.988353+00'),
	('f2cd7ce0-d716-4c0e-abcf-27dd08c26186', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:14.824282+00'),
	('d6e85c81-6c94-47ec-b6d3-56f2353fc939', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:15.857068+00'),
	('e51a35bc-7c72-4c37-9d00-fc354e2877cb', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:17.366982+00'),
	('a3737da5-dddd-441d-951b-b585784b0a04', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:19.205071+00'),
	('62813092-0df2-4c17-b7a0-903e4b80e4fd', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:20.632203+00'),
	('8b248016-2033-4efc-b6a1-40d467927cf2', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:22.54654+00'),
	('d3155a24-798d-4d17-b0c3-f7b06211b681', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 14:41:23.174657+00'),
	('447fdf17-8d0f-436e-a461-3dfcdd388739', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 9, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:41:23.398527+00'),
	('b6d63152-1a8a-4a1f-9d82-e2378cf50942', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:41:29.231798+00'),
	('3b83e2c7-0071-4b45-a402-d007f33e6384', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:41:36.747008+00'),
	('17a19f9c-454d-44da-b940-bcf0659370cd', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 14:41:40.03138+00'),
	('83e668fa-b0ed-40b6-8f45-6c7b19976f1a', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:19.643696+00'),
	('f7b17cfe-b4aa-49c9-848b-d510d0129cb1', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:51:19.782889+00'),
	('618f8791-4ffe-4279-bb4b-e2ef88cd77f4', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "high"}', 'Submitted community vote', '2026-01-11 07:51:20.496313+00'),
	('0a1c9578-2905-4b5e-8e48-b1264fee4acb', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 07:51:20.638521+00'),
	('a954805b-0151-4b6d-b4ad-5dc99e7f8949', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:22.146846+00'),
	('fbb3c811-acd3-44d9-a76e-a1bf282959a4', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:51:22.253194+00'),
	('6e4faa73-88fe-4c34-b003-9220644ee075', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:23.43958+00'),
	('76eb6df6-3e79-40e6-ac8c-d5fa6122af1d', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:51:23.59433+00'),
	('7e84401f-7950-4f67-ae27-e6e4e44366d8', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:25.150108+00'),
	('1e73ec74-d7f5-4624-826d-822ca9b79471', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 9, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:51:25.292599+00'),
	('ae50a721-4729-464f-8105-98095610b8ca', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:51:25.896913+00'),
	('c7bfa394-64f4-4220-a4e1-cd0c02370f09', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 4, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 07:51:37.058954+00'),
	('522e127c-f5aa-4eb2-80c6-21967430dd80', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 09:02:34.321819+00'),
	('acc4c4f6-24f1-464e-9074-9b4e90215ccd', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 09:02:34.811283+00'),
	('a51f973f-06ae-4bce-8e2b-64d80b56b8cb', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 09:02:35.311217+00'),
	('4ca2e71b-d5c8-43a7-9293-0c12a6c9ca3b', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'rfc_submit', NULL, NULL, NULL, 'c9f2a5ba-0b80-4d9f-912d-e79889afaa20', '{"metric_id": null, "proposal_type": "new_metric"}', 'Submitted RFC proposal', '2026-01-15 03:20:17.821238+00'),
	('db81d96e-164c-4abd-9f92-b299edf7259f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 15, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.311222+00'),
	('c45db257-3ef7-4193-b055-3ea149d4b975', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 12, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.405926+00'),
	('7592529b-227c-440c-9857-4b9e4142952b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 11, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.070349+00'),
	('8f87d0a1-13ab-40bd-9286-5956bb34ea2c', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 17, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.101273+00'),
	('de532e64-0b04-4ca6-9160-14f30b9ac721', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 11, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.800989+00'),
	('7aa9c977-9273-41a5-823e-fa9a6ee7b237', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 15, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.831149+00'),
	('ac4d0209-b3bb-4d8e-bc06-861e38444749', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 6, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.904011+00'),
	('7c12e7d2-9020-4f40-9d6c-4c4b9e9bfb0f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 10, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.924768+00'),
	('b1ac8e1b-5ae4-433e-aa8e-4cb8f9517caf', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-15 11:21:18.384866+00'),
	('53633a87-36a8-4c3f-a45d-d1d3f3e24f0e', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-15 11:21:19.102144+00'),
	('f49238db-f886-4138-96a9-1838a4fab888', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 10, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.294428+00'),
	('454ea11b-3608-4e61-8cf8-27fb0d06f757', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 8, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.080061+00'),
	('051fa534-0485-4a1b-9198-4f7d1a76f5c3', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 17, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.857546+00'),
	('52c4fd17-7091-4c35-9c17-8b83b7491d77', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 18, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.919716+00'),
	('ce9b6237-88b7-4e74-b461-d447788a45f0', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 5, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.936407+00'),
	('7c035b7e-8b8f-4aa2-99c7-7e29a109900e', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:31:46.707892+00'),
	('ee01586c-63e6-4cdb-98ca-32953793a1ae', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "high"}', 'Submitted community vote', '2026-01-11 07:35:22.32067+00'),
	('f2b73d2c-78ec-496e-a95e-55b0137cec15', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:35:27.203993+00'),
	('4cf958f2-b0db-4fc9-b695-68357da66957', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:35:28.717682+00'),
	('cafdaed3-cc2d-4c99-9fae-c5a32041681e', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 07:35:28.855415+00'),
	('4f3bb26d-506b-4232-8c28-69f4c27d0ff2', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:35:29.763576+00'),
	('83a9766f-7292-4b97-8986-60351129207c', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:35:30.859531+00'),
	('b2a6cb26-d307-4e73-9a6a-7a3bdc0450c9', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:35:32.23369+00'),
	('88a821c2-90df-4b7a-b4a8-8068c55c3a90', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 07:35:33.006074+00'),
	('8a3b5e51-3531-404f-adb9-07a6eba81ae6', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:19:17.75139+00'),
	('ab8f5dd6-0e6a-41be-9d2e-817f8a47b1e3', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:19:18.11923+00'),
	('8957647e-6afb-4c7d-afc8-036175fd3a50', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:19:34.996313+00'),
	('efea7725-0763-4ce4-ad94-f5355aba916b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:21.083259+00'),
	('32e31af4-4f43-4290-adc8-d21982e18eab', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:21.763251+00'),
	('a469f686-d882-45e3-b669-197bb3a9bbae', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:22.749835+00'),
	('f590fc97-7142-48ad-b74e-9905a432f789', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:23.479555+00'),
	('a357f53f-d8fe-40bf-b016-a35b4787499e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:23.70451+00'),
	('5871f8f1-c309-4879-a57e-8536319ca8a8', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:22:24.741995+00'),
	('bce47743-80c4-42c4-a6ee-7455c8494ecb', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:24.936113+00'),
	('3fd22320-09e4-4977-b46e-36f58e9c2e19', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:22:29.946635+00'),
	('df662f97-58ea-452f-9d02-0c83a959194c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:22:35.773714+00'),
	('0af977db-7961-4d3b-81b9-9ee6817a5cfb', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:22:36.02228+00'),
	('9563e0db-c7ff-4fb4-b196-4624383ecd0f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:23:52.374775+00'),
	('0ded9086-6c31-4045-8be7-64ac7209ce6d', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:23:53.043793+00'),
	('e9e42288-47c9-4d2a-a0ac-715e72f8de3a', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:23:54.343081+00'),
	('4163286a-9739-4efe-a272-0c788e410844', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:24:01.539806+00'),
	('e05d93a6-0389-4b64-b161-1de374393375', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:24:02.148123+00'),
	('505351ea-9bca-4cbf-9819-5f868f1af69f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:24:03.994406+00'),
	('751112fa-c717-4b80-b6aa-6d9dbab86e45', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:24:05.674419+00'),
	('f1d965e7-c4b6-4dc7-bb7a-4cbcc2829c4e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:24:06.196102+00'),
	('8536389e-c3b5-4548-b15c-5a87c8d20ff2', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:24:09.864659+00'),
	('27130f41-5ca5-4063-83af-812f60bbc53b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:24:12.30099+00'),
	('26fd27f2-e058-423b-9616-1974b185e7be', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:24:13.421279+00'),
	('48e6be7f-45a1-43a1-bb0a-3988bc4b6e3e', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 11:24:17.565109+00'),
	('6c9c41e0-7ab3-4a50-a26f-23a7482d4f2b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-16 18:13:32.760767+00'),
	('429fb12a-6fb5-44c1-9468-b4f5bccee5b4', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-16 18:13:33.298046+00'),
	('482ea8fb-5b4d-4b6e-a178-e9c4d27c62cc', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "low"}', 'Updated community vote', '2026-01-10 23:24:35.237821+00'),
	('0eee318f-9b4c-4eab-b33b-423e8988a24e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:36:37.840274+00'),
	('cd8617d5-a35d-4a4e-b412-829d80fa086d', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-10 23:36:47.717818+00'),
	('aa9f808a-099a-4aa4-bea5-d281f9e5f3d2', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:52:10.895357+00'),
	('4547939f-008e-4eef-8610-8601ace9368b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:52:11.67318+00'),
	('83602429-a245-4f4e-9e01-0a0c88d0c79c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:52:12.602745+00'),
	('1352a077-e19c-4226-bcf8-60d761e0ac5f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "low"}', 'Updated community vote', '2026-01-10 23:52:14.045737+00'),
	('c4fdf424-22c3-4cbc-b78a-03b9f19dfa84', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "low"}', 'Updated community vote', '2026-01-10 23:52:14.593343+00'),
	('31ae310d-ab43-405d-af72-413d4337d875', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-10 23:52:20.196579+00'),
	('de813cbb-06f5-41a5-a573-2dcf6b3cb489', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:14:41.165107+00'),
	('d78651f9-783c-4876-b21e-cc716fd0391f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:14:41.40307+00'),
	('7b69672b-92ff-42aa-ab1f-6a958b32cc0b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:14:42.343343+00'),
	('b4a8cbfe-9299-4051-a205-ad42fe0a3221', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:15:52.333683+00'),
	('1ba98091-235d-439e-bc51-b0471e1262f8', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:15:52.733034+00'),
	('65089aa5-0c8e-4cd0-9ac9-28a398b5ad17', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:22:30.073798+00'),
	('1089c1a4-a505-420c-bf4d-cb79c9760d81', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 00:22:32.467783+00'),
	('b14701d1-45a4-404f-b121-6703fa228def', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:22:37.950075+00'),
	('423f781f-bb9d-4c5d-898c-aeab1608dd38', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:12.313841+00'),
	('85a27c93-35e2-4e44-9b33-412620c82ffd', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "low"}', 'Updated community vote', '2026-01-11 00:54:19.410942+00'),
	('8321c6e2-f07f-4a0d-98f2-9ef5df74150f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:20.523572+00'),
	('1905e7ac-5735-4f04-8bae-6c92bc5f21f2', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 4, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:22.027102+00'),
	('4dc53d6e-7a5c-4927-87be-386e2e049f80', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 6, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:24.182284+00'),
	('150df867-b2d4-4fae-a27d-277e09269d2f', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:25.486913+00'),
	('50efefb2-0456-43ef-992f-d6b17d7d4cda', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:26.474397+00'),
	('86f20dcf-89ec-4ac8-b359-15bc2c2723fe', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:31.967244+00'),
	('3d069f41-d3aa-41e5-918b-b7911150ce7a', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:41.781027+00'),
	('7bb260cf-12f5-4d2d-8d28-3d501d852149', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:42.175808+00'),
	('f3809310-ed69-4485-b221-2c741a65a34d', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:45.095087+00'),
	('4743478c-8c18-4fd5-81c1-4e97bec7d6a8', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 00:54:47.38203+00'),
	('e3ea5fb8-5dad-4821-875e-b3d2cde26aad', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 03:07:34.349248+00'),
	('81d09c91-d8ad-4e07-9b74-a3323a252e3b', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:42.146899+00'),
	('6eede05e-dcd6-440a-8d58-61991680d2a8', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 04:57:43.299639+00'),
	('7398b29d-691f-4274-8e89-007065b36d13', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:44.809743+00'),
	('518908de-10c2-4103-afde-85fd2c276579', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:46.373987+00'),
	('7b6482fe-e411-4abe-a2bd-f4862b27f2fe', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:49.4281+00'),
	('ad5ccc2c-2c75-403d-8fd1-07ae3c3d54ae', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:50.363203+00'),
	('531a2f75-b2d6-4fbe-af5f-760e883a98c0', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:51.537049+00'),
	('d4306c51-ee69-46a6-bd74-672254b07b93', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:54.478507+00'),
	('e5223f99-dd56-4292-87d2-37456ad152f0', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:57.836686+00'),
	('96c58657-9ba7-4a02-955a-d47f0be4cc80', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:57:59.096396+00'),
	('0167d6ac-2ca4-42d1-ac42-d700f87f504d', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 9, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 04:57:59.827235+00'),
	('5399ed34-ec52-472a-bd60-928f08ba924f', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 04:58:01.098813+00'),
	('934974d7-b6a5-4346-af67-fa87261bc476', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 04:58:01.772874+00'),
	('dd085ee2-f4f0-49f2-8476-c79a259ea1d4', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:03:58.066521+00'),
	('4ce249ec-09fc-4adc-9bcc-ea207208a5bf', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:03:59.86051+00'),
	('e255690f-b505-41de-b505-6e6d769b465f', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:04:03.380778+00'),
	('fde55a39-8ae0-4ad5-a20d-a6a71aa69149', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:05:31.28675+00'),
	('ce9a6432-a80e-4859-8a4d-d059e076f5df', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:05:31.940668+00'),
	('3fa7fe7f-e46a-4736-aa6f-56104a1fc3d8', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:05:32.509287+00'),
	('8858c67d-0bf0-4af2-a9e9-8e54e51b3346', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:05:35.564249+00'),
	('cf3633fa-3ab1-4eb6-be8e-ae7c642ccd0b', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 05:05:36.035555+00'),
	('30848174-f6b3-498d-b2c5-4579c0f5b9cc', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:47.918597+00'),
	('f97f6322-15ee-45d0-99d4-bbade0fabf88', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:48.668406+00'),
	('44fc1ffc-bf0e-4d37-acab-30247db547f5', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:50.241384+00'),
	('4328157b-bf05-4576-9945-37c294542647', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:06:50.400414+00'),
	('70c451b4-c4d9-4e74-9f12-d7961acd7fe6', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 4, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:51.910793+00'),
	('ec60058d-4abd-4e5a-a371-2bf2907fd8a1', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:53.177263+00'),
	('77a4f84b-744d-4f9e-84a7-9d081e8fa81a', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:06:53.320549+00'),
	('73ec03bf-bbf3-4108-b67a-02d242322d13', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 6, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:54.749311+00'),
	('ec58266f-1276-47cf-938a-4d4a3cae2bc6', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 7, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:56.12845+00'),
	('4e3fc715-ccc0-4bf5-ba79-3931b3e29027', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:57.304548+00'),
	('088d3fbd-b29c-45c6-a6c9-34901931a4d5', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 06:06:58.296399+00'),
	('4ee2b378-61e7-4e2c-960d-0d5d91920ec4', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 10, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:06:58.42095+00'),
	('377bf8e5-e66a-4fbb-aabf-ec177fe29b6f', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "high"}', 'Updated community vote', '2026-01-11 06:52:30.741519+00'),
	('546e4a87-d064-42a8-95f0-016b449190aa', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:52:33.097416+00'),
	('6b1412e0-f6d6-4660-8f92-e8e677e575d8', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:52:33.557871+00'),
	('7dcb9fdf-ce81-4c30-a5af-61d0e78291c4', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:52:35.291174+00'),
	('7fb77e37-e3ae-48c2-a0a8-0f25ea465041', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 06:52:35.408749+00'),
	('af0b3873-f745-4d91-8bbd-6adf4d9ea494', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 5, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 09:02:58.993935+00'),
	('f3d981e3-8ba8-4738-b818-f2a100c9082e', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 7, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "low"}', 'Updated community vote', '2026-01-11 09:03:00.887546+00'),
	('4c7756e9-14df-4b83-9fd0-dfe506c0f2ce', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 8, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 09:03:03.192661+00'),
	('edbc5c40-d340-4825-bc9e-5d7a36148f34', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 09:03:10.327104+00'),
	('61a548c8-b99e-4c1b-aa2c-65d574296878', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:21:16.893774+00'),
	('7f761f71-284f-4835-a017-91997c017252', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:21:17.39316+00'),
	('a0c6be91-3ae9-41b4-8be7-6af8c2b71ec2', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 2, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 10:21:29.180531+00'),
	('bf5c13e3-f1e4-4b67-9594-2fae11b7fc2d', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 10:21:30.114891+00'),
	('8214dd02-be86-402c-9070-c449e18a403e', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 8, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:12.698505+00'),
	('47377459-59df-4e6f-bd58-77087064d09d', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 9, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:13.742033+00'),
	('fd1d76c1-2a6b-4e3f-bc85-e0d8c17db93c', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 10, NULL, NULL, '{"is_new": true, "vote_value": 2, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-11 13:19:14.930591+00'),
	('be3eeaca-9600-4dc1-991e-7a27ff10fcb0', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:19:21.220708+00'),
	('ac6165d0-1cbe-4c4e-be8c-d1a5fc9e4a14', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-11 13:19:21.714503+00'),
	('a6dccd97-6bd4-4345-927c-cbffeb4db694', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 04:04:51.00628+00'),
	('1caf97b3-f0f4-4d77-a1bb-5e6cf304d9d7', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 04:04:51.462105+00'),
	('1b720458-0b68-43fa-8916-14354c1cc893', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": true, "vote_value": 1, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-17 01:39:25.018734+00'),
	('73a67a41-8c6f-4f67-8c17-a475b7b1d160', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 2, "confidence_level": "medium"}', 'Updated community vote', '2026-01-17 01:39:25.244918+00'),
	('cdf4bd79-0052-4e3e-b968-94021ad6ab62', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-17 01:39:30.972107+00'),
	('c04a087c-b667-470d-8541-2ea502fca330', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": true, "vote_value": 3, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-15 11:21:20.181229+00'),
	('7ac4f459-5ed9-48de-8c4c-3cfd4c5fd00f', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 3, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 11:21:21.740965+00'),
	('9f33448a-4d79-4b02-bac6-8558f8233980', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 2, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 11:21:22.541737+00'),
	('dda7a30c-30d9-4061-9ba2-a23a7c8ae3e9', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 11:21:23.375254+00'),
	('c725e3d8-2b30-4542-825d-4d0d68dac57c', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 11:21:23.661201+00'),
	('3247fa1e-5299-4cc0-a02c-54f857f4c727', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 1, "confidence_level": "medium"}', 'Updated community vote', '2026-01-15 11:24:11.574449+00'),
	('ce638511-6bd7-47ba-8aae-c00879cd2a19', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 3, "confidence_level": "medium"}', 'Updated community vote', '2026-01-16 18:13:33.973047+00'),
	('8b3835f7-efc5-41cd-8033-606543416413', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-16 18:13:34.862787+00'),
	('0e55225a-eb90-4a63-9f2f-e1944bf0d723', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', NULL, 1, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-16 18:13:35.375198+00'),
	('79e2740f-f7db-4690-91b7-5a61c7996a85', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 5, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.283764+00'),
	('22a0c596-517d-44f1-8cca-fb45d0e6770e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 16, NULL, NULL, '{"is_new": true, "vote_value": 5, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-20 23:04:46.397975+00'),
	('42f5eb53-90c9-4c98-b323-fdf1c61bc782', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 19, NULL, NULL, '{"is_new": false, "vote_value": 5, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.070347+00'),
	('a66033a3-d53c-4d87-bd6d-6e8f8c94d0e8', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'aaro-report-vol1-2024', 18, NULL, NULL, '{"is_new": false, "vote_value": 4, "confidence_level": "medium"}', 'Updated community vote', '2026-01-20 23:05:59.15767+00'),
	('bffb8530-c481-4a14-8feb-22f302cecafe', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'vote', 'congressional-scif-jan-2024', 14, NULL, NULL, '{"is_new": true, "vote_value": 4, "confidence_level": "medium"}', 'Submitted community vote', '2026-01-24 04:36:22.958304+00');


--
-- Data for Name: target_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."target_submissions" ("id", "target_name", "case_id", "origin", "context", "description", "source_url", "claim_date", "primary_source", "additional_notes", "status", "submitted_by", "submitted_at", "reviewed_by", "reviewed_at", "review_notes", "created_at", "updated_at") VALUES
	('46d3f260-5604-40b4-822b-5809c630cce5', 'Varhgina Brazillan ', 'QDD-PRIV-MEDIA_BROADCAST-0031', 'private_sector_corporate', 'media_broadcast', 'https://www.youtube.com/watch?v=99hRVeBzTzE', 'https://www.youtube.com/watch?v=99hRVeBzTzE', '2026-01-20', 'News Nation', NULL, 'approved', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-20 22:51:37.091082+00', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-20 22:57:22.956756+00', NULL, '2026-01-20 22:51:37.091082+00', '2026-01-20 22:57:22.956756+00'),
	('835e41b0-0016-45b1-bf42-69e755e97962', 'Sol Foundation Symposium 2023', 'QDD-001-UNK-0013', 'academic_institution', 'academic_symposium', 'Academic symposium on UAP disclosure hosted by Sol Foundation', NULL, '2023-11-01', 'Sol Foundation', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('6b62a063-ad7e-42fe-8090-ea7e33a0859a', 'David Grusch - NewsNation Interview', 'QDD-001-UNK-0014', 'private_sector_corporate', 'media_broadcast', 'NewsNation interview with David Grusch discussing UAP disclosure', NULL, '2023-06-11', 'NewsNation', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('fd2c9262-d2d6-4b11-a3e3-281cd73b8386', 'Congressional SCIF Briefing (Jan)', 'QDD-001-UNK-0015', 'legislative_branch', 'classified_proceeding', 'Classified briefing to Congressional members regarding UAP', NULL, '2024-01-15', 'US Congress', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('a6d8fdff-01e5-41e4-b30a-902e4d5c2669', 'Jellyfish UAP Video Release', 'QDD-001-UNK-0016', 'independent_researcher', 'visual_evidence', 'Release of alleged UAP video footage showing jellyfish-like object', NULL, '2024-01-10', 'Jeremy Corbell', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('f6b0755a-31f6-491c-86a2-9f8fd84d1ffd', 'Nazca Mummies (Initial Release)', 'QDD-001-UNK-0017', 'independent_researcher', 'forensic_claim', 'Initial public presentation of alleged non-human mummies from Peru', NULL, '2023-09-13', 'Jaime Maussan', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('910e7f30-a003-46da-8215-82c27684a72f', 'Miami Mall Incident (Social Media)', 'QDD-001-UNK-0018', 'unspecified', 'viral_narrative', 'Social media viral narrative regarding alleged incident at Miami mall', NULL, '2024-01-03', 'Social Media', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('a30c77cf-1ae4-42f8-b343-b894806fe885', 'AARO Historical Report Vol 1', 'QDD-001-UNK-0019', 'dod_joint', 'government_report', 'All-domain Anomaly Resolution Office historical report volume 1', NULL, '2024-02-29', 'AARO/DoD', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('8f2cdd21-e4cb-4a17-8446-47b64d376e66', 'Kirsan Ilyumzhinov Interview', 'QDD-001-UNK-0020', 'media_organization', 'witness_testimony', 'Interview with former FIDE president regarding alleged UAP encounter', NULL, '2023-10-15', 'Various Media', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('f2f6b9a1-5fe0-45e9-b98d-eb69b4b1a743', 'Danny Sheehan - Disclosure Project', 'QDD-001-UNK-0021', 'ngo_thinktank', 'public_statement', 'Public statement and disclosure initiative from attorney Danny Sheehan', NULL, '2023-12-01', 'New Paradigm Institute', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-19 00:18:44.897897+00', 'Prototype UI Seed Data', '2026-01-19 00:18:44.897897+00', '2026-01-20 22:49:19.269393+00'),
	('bd570e38-57a9-42aa-8d07-d5544517dcfc', 'Sol Foundation Symposium 2023', 'QDD-ACAD-ACADEMIC_SYMPOSIUM-0022', 'academic_institution', 'academic_symposium', 'Academic symposium on UAP disclosure hosted by Sol Foundation', NULL, '2023-11-01', 'Sol Foundation', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('35e55a46-22d8-44a3-afb3-a47834675fde', 'David Grusch - NewsNation Interview', 'QDD-PRIV-MEDIA_BROADCAST-0023', 'private_sector_corporate', 'media_broadcast', 'NewsNation interview with David Grusch discussing UAP disclosure', NULL, '2023-06-11', 'NewsNation', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('be886a12-6fa9-4225-ba1b-dba36fe8604d', 'Congressional SCIF Briefing (Jan)', 'QDD-CONG-CLASSIFIED_PROCEEDING-0024', 'legislative_branch', 'classified_proceeding', 'Classified briefing to Congressional members regarding UAP', NULL, '2024-01-15', 'US Congress', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('89eac47b-ecc2-469a-a8a6-6cd09d7da001', 'Jellyfish UAP Video Release', 'QDD-IND-VISUAL_EVIDENCE-0025', 'independent_researcher', 'visual_evidence', 'Release of alleged UAP video footage showing jellyfish-like object', NULL, '2024-01-10', 'Jeremy Corbell', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('12573f6f-4e14-4084-937d-1a00da2b5a89', 'Nazca Mummies (Initial Release)', 'QDD-IND-FORENSIC_CLAIM-0026', 'independent_researcher', 'forensic_claim', 'Initial public presentation of alleged non-human mummies from Peru', NULL, '2023-09-13', 'Jaime Maussan', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('c84035dd-8ca0-4703-ac11-6c1c31c0ff8e', 'Miami Mall Incident (Social Media)', 'QDD-UNK-VIRAL_NARRATIVE-0027', 'unspecified', 'viral_narrative', 'Social media viral narrative regarding alleged incident at Miami mall', NULL, '2024-01-03', 'Social Media', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('6cdadc3f-af6a-4ce1-a011-d72014300a94', 'Eric Hecker', 'QDD-001-USN-0003', 'dod_usn', 'internal', 'sdfdfsdfsdfdsfdsf', 'https://deciphering.tv', '2001-01-01', 'Redacted', 'sdfasdfsdfdsfdsfds', 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 00:56:17.458604+00', NULL, '2026-01-17 01:57:44.213+00', '', '2026-01-11 00:56:17.458604+00', '2026-01-20 22:49:19.269393+00'),
	('17b2e2f7-16e4-4c80-adc4-4aac8ad71150', 'AARO Historical Report Vol 1', 'QDD-DOD-GOVERNMENT_REPORT-0028', 'dod_joint', 'government_report', 'All-domain Anomaly Resolution Office historical report volume 1', NULL, '2024-02-29', 'AARO/DoD', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('6867f481-bdc0-483d-964f-dc71399e9aab', 'Kirsan Ilyumzhinov Interview', 'QDD-MEDIA-WITNESS_TESTIMONY-0029', 'media_organization', 'witness_testimony', 'Interview with former FIDE president regarding alleged UAP encounter', NULL, '2023-10-15', 'Various Media', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('fbdb7187-b89b-426e-bbc8-8692c1ec1064', 'Danny Sheehan - Disclosure Project', 'QDD-NGO-PUBLIC_STATEMENT-0030', 'ngo_thinktank', 'public_statement', 'Public statement and disclosure initiative from attorney Danny Sheehan', NULL, '2023-12-01', 'New Paradigm Institute', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-20 22:49:19.001102+00', 'Prototype UI Seed Data', '2026-01-20 22:49:19.001102+00', '2026-01-20 22:49:19.269393+00'),
	('34d88ae9-8086-431d-8055-6edebb2098fe', 'Grusch_T_2024', 'NCI-8.3-XREF-QDD', 'ic_national', 'congressional_hearing', 'David Grusch UAP disclosure testimony before Congress', NULL, '2023-07-26', 'Congressional Record', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-13 08:46:04.53809+00', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-17 02:17:27.575198+00', '', '2026-01-13 08:46:04.53809+00', '2026-01-20 22:49:19.269393+00'),
	('708d5f36-a69f-42c3-b863-c90e66b8d7ec', 'Eric Hecker', 'QDD-001-DOD-0007', 'dod_joint', 'congressional_hearing', 'Redacted YouTube', 'https://deciphering.tv', '2001-01-01', 'Redacted', 'sdfsdfdssd', 'approved', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', '2026-01-11 06:06:35.458703+00', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-17 02:18:15.187558+00', NULL, '2026-01-11 06:06:35.458703+00', '2026-01-20 22:49:19.269393+00'),
	('0cd8f273-1dd7-4151-aa58-4f18455bb95e', 'Eric Hecker', 'QDD-001-DOD-0004', 'dod_joint', 'internal', 'werwe', 'https://deciphering.tv', '2001-01-01', 'df', 'sadfsadfs', 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 02:40:15.753863+00', NULL, '2026-01-17 01:42:00.94+00', '', '2026-01-11 02:40:15.753863+00', '2026-01-20 22:49:19.269393+00'),
	('95927850-9168-435f-8aeb-e275b8f6cf0e', 'Wilson_Memo_2002', 'NCI-7.1-XREF-QDD', 'dod_joint', 'internal', 'Eric Davis notes from Admiral Wilson meeting', NULL, '2002-10-16', 'Eric Davis Notes', NULL, 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-13 08:46:04.53809+00', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-17 02:14:55.628005+00', '', '2026-01-13 08:46:04.53809+00', '2026-01-20 22:49:19.269393+00'),
	('4d585295-9842-494c-8444-efdff2536c7f', 'fasadfgsadfsdfds', 'QDD-001-USN-0006', 'dod_usn', 'internal', 'sdfsdf', 'https://deciphering.tv', '2001-01-01', 'sdfdsf', 'sdfsdfsdfsd', 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 03:06:16.039336+00', NULL, '2026-01-17 01:41:49.831+00', '', '2026-01-11 03:06:16.039336+00', '2026-01-20 22:49:19.269393+00'),
	('6bed0638-9c24-4923-adfe-c278f6e2a788', 'fghfghf', 'QDD-001-DOD-0002', 'dod_joint', 'operational', 'fghfgh', NULL, '2002-02-22', 'fhg', NULL, 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 00:11:00.107619+00', NULL, '2026-01-17 01:41:55.488+00', '', '2026-01-11 00:11:00.107619+00', '2026-01-20 22:49:19.269393+00'),
	('87c88529-62db-43f1-9f37-70dd7902889e', 'csdsfsddsfsd', 'QDD-001-DOD-0012', 'dod_joint', 'operational', 'Desc Desc', 'https://deciphering.tv', '20001-01-01', 'PRIMARY', 'Any addiontal notes?', 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 13:49:20.084413+00', NULL, '2026-01-17 01:41:39.542+00', '', '2026-01-11 13:49:20.084413+00', '2026-01-20 22:49:19.269393+00'),
	('72138ded-eae6-49e6-a4d7-c4d2787a5046', 'SSSSSS', 'QDD-001-USN-0008', 'dod_usn', 'operational', 'J Rod The Alien''s story', NULL, '2001-12-05', 'J Rod', 'evil', 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 08:12:45.601012+00', NULL, '2026-01-17 01:41:46.907+00', '', '2026-01-11 08:12:45.601012+00', '2026-01-20 22:49:19.269393+00'),
	('b5cc59aa-b57d-42ef-a8d3-15f6e927030d', '134145131', 'QDD-001-USN-0005', 'dod_usn', 'operational', '34134', 'https://deciphering.tv', '23123-12-31', '12341314', 'dfgdfsgsdf', 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 02:43:37.275449+00', NULL, '2026-01-17 01:41:52.961+00', '', '2026-01-11 02:43:37.275449+00', '2026-01-20 22:49:19.269393+00'),
	('f4925b31-d28a-40bf-8beb-9994bcbac201', 'Nimitz_Encounter_2004', 'NCI-9.2-XREF-QDD', 'dod_usn', 'operational', 'USS Nimitz carrier strike group UAP encounter', NULL, '2004-11-14', 'US Navy', NULL, 'pending', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-13 08:46:04.53809+00', NULL, NULL, '', '2026-01-13 08:46:04.53809+00', '2026-01-20 22:49:19.269393+00'),
	('6966eb60-6e9e-4d08-afd5-aeb96ed0d708', 'Eric Hecker3', 'QDD-001-USN-0009', 'dod_usn', 'operational', 'Redacted', 'https://deciphering.tv', '2001-01-01', 'Redacted', NULL, 'pending', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', '2026-01-11 13:20:34.934855+00', NULL, NULL, '', '2026-01-11 13:20:34.934855+00', '2026-01-20 22:49:19.269393+00'),
	('21c9fbfa-661d-462a-9929-b1149e2b17a5', 'Eric Hecker', 'PRIV-1.0-MEDIA-0001', 'private_sector_corporate', 'media_interview', 'Eric J. Hecker was born and raised on Long Island in New York.

As a child he was part of the Stargate Program and later on he spent a short time in the Submarine Service where he first came across a peculiar program run by Raytheon.

In November of 2010 Eric was selected to be part of the United States Antarctic Program. He spent an entire year at the South Pole Station where he learned things were not as was being presented to the world. That is precisely why he is speaking out.

Eric has been seen on the T.V. series the Alaska Triangle, Redacted with Clayton Morris, The Shawn Ryan Show as well as many other podcasts for years now. He was also part of Dr. Steven Greer’s Disclosure 2.0 event in Washington D.C.

Eric is one of the few whistleblowers that was asked to give testimony for both the Senate Intelligence Committee and AARO. His shared testimony will be getting entered into the National Archives.

', 'https://deciphering.tv', '2025-09-09', 'Eric Hecker', NULL, 'pending', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', '2026-01-09 16:59:33.10304+00', NULL, NULL, NULL, '2026-01-09 16:59:33.10304+00', '2026-01-20 22:49:19.269393+00'),
	('5fcdce5b-a16b-4db6-a31d-63549a72bc1f', 'Bob Lagar', 'QDD-001-PRIV-0011', 'private_sector_corporate', 'media_interview', 'Bob Antigravity Lazar', NULL, '1990-01-01', 'George Knapp', 'Mp', 'approved', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 13:45:42.641275+00', '132fdb5d-3a06-406c-a87b-570b56028a4a', '2026-01-17 02:17:16.99094+00', '', '2026-01-11 13:45:42.641275+00', '2026-01-20 22:49:19.269393+00'),
	('845476a4-7f45-4c94-89d5-512af619dceb', 'sdfdsfsdfdsdfs', 'QDD-001-ACAD-0010', 'academic_institution', 'unspecified', 'dfssdds', NULL, '2001-11-11', 'David Grooosh', NULL, 'rejected', 'daf56408-129f-4ed7-9af5-1fefd84068ea', '2026-01-11 13:35:08.794105+00', NULL, '2026-01-17 02:19:34.256+00', '', '2026-01-11 13:35:08.794105+00', '2026-01-20 22:49:19.269393+00');


--
-- Data for Name: approved_targets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."approved_targets" ("id", "name", "case_id", "origin", "context", "description", "source_url", "claim_date", "primary_source", "verified", "submission_id", "created_at", "updated_at") VALUES
	('sol-foundation-2023', 'Sol Foundation Symposium 2023', 'QDD-ACAD-ACADEMIC_SYMPOSIUM-0010', 'academic_institution', 'academic_symposium', 'Academic symposium on UAP disclosure hosted by Sol Foundation', NULL, '2023-11-01', 'Sol Foundation', true, '835e41b0-0016-45b1-bf42-69e755e97962', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('grusch-newsnation-2023', 'David Grusch - NewsNation Interview', 'QDD-PRIV-MEDIA_BROADCAST-0011', 'private_sector_corporate', 'media_broadcast', 'NewsNation interview with David Grusch discussing UAP disclosure', NULL, '2023-06-11', 'NewsNation', true, '6b62a063-ad7e-42fe-8090-ea7e33a0859a', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('congressional-scif-jan-2024', 'Congressional SCIF Briefing (Jan)', 'QDD-CONG-CLASSIFIED_PROCEEDING-0012', 'legislative_branch', 'classified_proceeding', 'Classified briefing to Congressional members regarding UAP', NULL, '2024-01-15', 'US Congress', true, 'fd2c9262-d2d6-4b11-a3e3-281cd73b8386', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('jellyfish-uap-jan-2024', 'Jellyfish UAP Video Release', 'QDD-IND-VISUAL_EVIDENCE-0013', 'independent_researcher', 'visual_evidence', 'Release of alleged UAP video footage showing jellyfish-like object', NULL, '2024-01-10', 'Jeremy Corbell', false, 'a6d8fdff-01e5-41e4-b30a-902e4d5c2669', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('nazca-mummies-2023', 'Nazca Mummies (Initial Release)', 'QDD-IND-FORENSIC_CLAIM-0014', 'independent_researcher', 'forensic_claim', 'Initial public presentation of alleged non-human mummies from Peru', NULL, '2023-09-13', 'Jaime Maussan', false, 'f6b0755a-31f6-491c-86a2-9f8fd84d1ffd', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('miami-mall-jan-2024', 'Miami Mall Incident (Social Media)', 'QDD-UNK-VIRAL_NARRATIVE-0015', 'unspecified', 'viral_narrative', 'Social media viral narrative regarding alleged incident at Miami mall', NULL, '2024-01-03', 'Social Media', false, '910e7f30-a003-46da-8215-82c27684a72f', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('aaro-report-vol1-2024', 'AARO Historical Report Vol 1', 'QDD-DOD-GOVERNMENT_REPORT-0016', 'dod_joint', 'government_report', 'All-domain Anomaly Resolution Office historical report volume 1', NULL, '2024-02-29', 'AARO/DoD', true, 'a30c77cf-1ae4-42f8-b343-b894806fe885', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('ilyumzhinov-interview-2023', 'Kirsan Ilyumzhinov Interview', 'QDD-MEDIA-WITNESS_TESTIMONY-0017', 'media_organization', 'witness_testimony', 'Interview with former FIDE president regarding alleged UAP encounter', NULL, '2023-10-15', 'Various Media', false, '8f2cdd21-e4cb-4a17-8446-47b64d376e66', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('sheehan-disclosure-2023', 'Danny Sheehan - Disclosure Project', 'QDD-NGO-PUBLIC_STATEMENT-0018', 'ngo_thinktank', 'public_statement', 'Public statement and disclosure initiative from attorney Danny Sheehan', NULL, '2023-12-01', 'New Paradigm Institute', false, 'f2f6b9a1-5fe0-45e9-b98d-eb69b4b1a743', '2026-01-19 00:18:44.897897+00', '2026-01-19 00:18:44.897897+00'),
	('sdfsewerere', 'Grusch_T_2024', 'NCI-8.3-XREF-QDD', 'ic_national', 'congressional_hearing', 'David Grusch UAP disclosure testimony before Congress', NULL, '2023-07-26', 'Congressional Record', true, '34d88ae9-8086-431d-8055-6edebb2098fe', '2026-01-17 02:17:27.575198+00', '2026-01-17 02:17:27.575198+00'),
	('114141214414', 'Eric Hecker', 'QDD-001-DOD-0007', 'dod_joint', 'congressional_hearing', 'Redacted YouTube', 'https://deciphering.tv', '2001-01-01', 'Redacted', true, '708d5f36-a69f-42c3-b863-c90e66b8d7ec', '2026-01-17 02:18:15.187558+00', '2026-01-17 02:18:15.187558+00'),
	('wilson-memo-2002', 'Wilson_Memo_2002', 'NCI-7.1-XREF-QDD', 'dod_joint', 'internal', 'Eric Davis notes from Admiral Wilson meeting', NULL, '2002-10-16', 'Eric Davis Notes', true, '95927850-9168-435f-8aeb-e275b8f6cf0e', '2026-01-17 02:14:55.628005+00', '2026-01-17 02:14:55.628005+00'),
	('sdfsdfsdf ', 'Bob Lagar', 'QDD-001-PRIV-0011', 'private_sector_corporate', 'media_interview', 'Bob Antigravity Lazar', NULL, '1990-01-01', 'George Knapp', true, '5fcdce5b-a16b-4db6-a31d-63549a72bc1f', '2026-01-17 02:17:16.99094+00', '2026-01-17 02:17:16.99094+00'),
	('QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 'Varhgina Brazillan ', 'QDD-PRIV-MEDIA_BROADCAST-0031', 'private_sector_corporate', 'media_broadcast', 'https://www.youtube.com/watch?v=99hRVeBzTzE', 'https://www.youtube.com/watch?v=99hRVeBzTzE', '2026-01-20', 'News Nation', true, '46d3f260-5604-40b4-822b-5809c630cce5', '2026-01-20 22:57:22.956756+00', '2026-01-20 22:57:22.956756+00');


--
-- Data for Name: assessment_notes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: community_votes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."community_votes" ("id", "user_id", "target_id", "metric_id", "vote_value", "confidence_level", "rationale", "created_at", "updated_at", "vote_timestamp") VALUES
	('9b7bbf6a-7f49-4bb0-a885-85eb627f39cb', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 6, 3, 'medium', '', '2026-01-20 22:58:18.045511+00', '2026-01-20 22:58:18.045511+00', '2026-01-20 22:58:18.045511+00'),
	('916ffb1a-f3ab-44b3-bc4f-5c2103bb4b40', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 14, 2, 'medium', '', '2026-01-20 22:58:18.07429+00', '2026-01-20 22:58:18.07429+00', '2026-01-20 22:58:18.07429+00'),
	('b5a0cab2-772f-4159-88b0-1f478d489907', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 20, 4, 'medium', '', '2026-01-20 22:58:18.127535+00', '2026-01-20 22:58:18.127535+00', '2026-01-20 22:58:18.127535+00'),
	('c523827f-792a-4f56-9347-cc6b3abdfeac', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 12, 3, 'medium', '', '2026-01-20 22:58:18.141161+00', '2026-01-20 22:58:18.141161+00', '2026-01-20 22:58:18.141161+00'),
	('c215d179-89b0-43b9-ab66-e2f313652bca', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 15, 2, 'medium', '', '2026-01-20 22:58:18.129207+00', '2026-01-20 22:58:18.129207+00', '2026-01-20 22:58:18.129207+00'),
	('24a7e684-593a-4757-970e-87718f4db79c', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 19, 2, 'medium', '', '2026-01-20 22:58:18.124442+00', '2026-01-20 22:58:18.124442+00', '2026-01-20 22:58:18.124442+00'),
	('6d8e510d-38bc-41f4-a846-2a6f700f9e0b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 1, 4, 'medium', '', '2026-01-20 22:58:18.147531+00', '2026-01-20 22:58:18.147531+00', '2026-01-20 22:58:18.147531+00'),
	('a2deefb1-4f5f-4e26-bbd0-451dd7877ae6', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 5, 2, 'medium', '', '2026-01-20 22:58:18.150413+00', '2026-01-20 22:58:18.150413+00', '2026-01-20 22:58:18.150413+00'),
	('6a4ab992-e650-4fe0-bc3e-4aafda62a80d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 13, 3, 'medium', '', '2026-01-20 22:58:18.164447+00', '2026-01-20 22:58:18.164447+00', '2026-01-20 22:58:18.164447+00'),
	('b4ef332e-35f1-4845-9ee0-0dfc93b3946d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 17, 4, 'medium', '', '2026-01-20 22:58:18.182214+00', '2026-01-20 22:58:18.182214+00', '2026-01-20 22:58:18.182214+00'),
	('39ffb7f6-3132-4e0e-8e0b-61d6470f1f39', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 1, 4, 'medium', '', '2026-01-20 23:04:46.399847+00', '2026-01-20 23:05:58.960941+00', '2026-01-20 23:04:46.399847+00'),
	('7e0189d9-3d56-48bd-a277-8a090e4234ce', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 20, 4, 'medium', '', '2026-01-20 23:04:46.272498+00', '2026-01-20 23:05:58.965606+00', '2026-01-20 23:04:46.272498+00'),
	('5e59305d-5296-4720-b970-6489c16c3d61', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 2, 3, 'medium', '', '2026-01-20 23:04:46.344367+00', '2026-01-20 23:05:59.070027+00', '2026-01-20 23:04:46.344367+00'),
	('1bb1a7f2-a602-46e4-ad08-fe05edf2fea3', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 11, 4, 'medium', '', '2026-01-20 23:04:46.345016+00', '2026-01-20 23:05:59.070349+00', '2026-01-20 23:04:46.345016+00'),
	('8b2d690a-e1c4-4faa-8009-b586f8d5222e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 17, 4, 'medium', '', '2026-01-20 23:04:46.412174+00', '2026-01-20 23:05:59.101273+00', '2026-01-20 23:04:46.412174+00'),
	('05134516-edae-42ae-9b2e-6f600ad898f2', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 14, 4, 'medium', '', '2026-01-20 23:04:46.411813+00', '2026-01-20 23:05:59.101011+00', '2026-01-20 23:04:46.411813+00'),
	('1019a270-f98b-4386-a603-aebc24e05068', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 10, 4, 'medium', '', '2026-01-20 23:04:46.294428+00', '2026-01-20 23:05:59.161084+00', '2026-01-20 23:04:46.294428+00'),
	('14473e59-cc73-4eac-b36d-68c1096c621f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 18, 4, 'medium', '', '2026-01-20 23:04:46.33651+00', '2026-01-20 23:05:59.15767+00', '2026-01-20 23:04:46.33651+00'),
	('d7aed47a-e93d-43c3-a7a0-815bb4af07b6', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 1, 3, 'medium', '', '2026-01-20 23:35:09.718651+00', '2026-01-20 23:35:09.718651+00', '2026-01-20 23:35:09.718651+00'),
	('64da4992-1921-42c0-bd2d-fbf59b1eaab5', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 9, 4, 'medium', '', '2026-01-20 23:35:09.803627+00', '2026-01-20 23:35:09.803627+00', '2026-01-20 23:35:09.803627+00'),
	('75f51233-2e5d-44fd-91cb-dd1bee57dfab', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 4, 5, 'medium', '', '2026-01-20 23:35:09.908111+00', '2026-01-20 23:35:09.908111+00', '2026-01-20 23:35:09.908111+00'),
	('26b87e32-3d49-419f-9d4c-1aab00eb5714', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 7, 5, 'medium', '', '2026-01-20 23:35:09.83626+00', '2026-01-20 23:35:09.83626+00', '2026-01-20 23:35:09.83626+00'),
	('150de21b-4f21-44e9-9f80-49b8f7da9e1d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 13, 4, 'medium', '', '2026-01-24 04:36:22.741273+00', '2026-01-24 04:36:22.741273+00', '2026-01-24 04:36:22.741273+00'),
	('937ad25d-9013-43f7-9860-dab585bdbf43', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 3, 4, 'medium', '', '2026-01-24 04:36:22.765959+00', '2026-01-24 04:36:22.765959+00', '2026-01-24 04:36:22.765959+00'),
	('458e79fc-fc33-468b-a00e-4e69fe318e1a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 2, 3, 'medium', '', '2026-01-24 04:36:22.829987+00', '2026-01-24 04:36:22.829987+00', '2026-01-24 04:36:22.829987+00'),
	('2fe8ce16-37c2-4cd6-b601-1cdfc5f61f8f', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 16, 4, 'medium', '', '2026-01-24 04:36:22.834971+00', '2026-01-24 04:36:22.834971+00', '2026-01-24 04:36:22.834971+00'),
	('836cf0e6-ecb4-4439-8c2f-b233c6798e57', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 17, 3, 'medium', '', '2026-01-24 04:36:22.857546+00', '2026-01-24 04:36:22.857546+00', '2026-01-24 04:36:22.857546+00'),
	('6c4fa73f-fb89-4654-9153-b577e5e58ac2', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 9, 4, 'medium', '', '2026-01-24 04:36:22.898185+00', '2026-01-24 04:36:22.898185+00', '2026-01-24 04:36:22.898185+00'),
	('378d3935-53e3-462d-b848-09ced5970e22', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 18, 4, 'medium', '', '2026-01-24 04:36:22.919716+00', '2026-01-24 04:36:22.919716+00', '2026-01-24 04:36:22.919716+00'),
	('9b2b76b3-9285-4d0c-856b-fcbe1fb0120b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 12, 4, 'medium', '', '2026-01-24 04:36:22.91956+00', '2026-01-24 04:36:22.91956+00', '2026-01-24 04:36:22.91956+00'),
	('cf3c0f19-293b-4b7a-93ce-26b35b42cdba', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 19, 4, 'medium', '', '2026-01-24 04:36:22.924568+00', '2026-01-24 04:36:22.924568+00', '2026-01-24 04:36:22.924568+00'),
	('7eca02c4-3991-4a98-80ac-c332f7846f81', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 20, 3, 'medium', '', '2026-01-24 04:36:22.950285+00', '2026-01-24 04:36:22.950285+00', '2026-01-24 04:36:22.950285+00'),
	('6b9baad4-f75a-46c4-bade-14963e743b5a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 5, 4, 'medium', '', '2026-01-24 04:36:22.936407+00', '2026-01-24 04:36:22.936407+00', '2026-01-24 04:36:22.936407+00'),
	('942b2731-e76e-4977-9f62-6ea66bb8da15', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 3, 3, 'medium', '', '2026-01-20 22:58:18.015293+00', '2026-01-20 22:58:18.015293+00', '2026-01-20 22:58:18.015293+00'),
	('2960b5c3-ec1c-4b30-b665-67931c297a40', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 7, 4, 'medium', '', '2026-01-20 22:58:18.061026+00', '2026-01-20 22:58:18.061026+00', '2026-01-20 22:58:18.061026+00'),
	('78e866b7-0b1c-4350-90c1-ff52fc492733', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 16, 2, 'medium', '', '2026-01-20 22:58:18.125412+00', '2026-01-20 22:58:18.125412+00', '2026-01-20 22:58:18.125412+00'),
	('44771b67-1906-43a6-8f64-871aea131bcb', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 11, 3, 'medium', '', '2026-01-20 22:58:18.133262+00', '2026-01-20 22:58:18.133262+00', '2026-01-20 22:58:18.133262+00'),
	('64e67a75-d861-4f16-8288-7b85c17c5b12', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 9, 3, 'medium', '', '2026-01-20 22:58:18.126602+00', '2026-01-20 22:58:18.126602+00', '2026-01-20 22:58:18.126602+00'),
	('f1e4fe7a-2ea3-4b7a-9e91-3ce2a663e69a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 4, 4, 'medium', '', '2026-01-20 22:58:18.105447+00', '2026-01-20 22:58:18.105447+00', '2026-01-20 22:58:18.105447+00'),
	('fda4455e-cfa3-4375-bef6-302e4c98320b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 10, 3, 'medium', '', '2026-01-20 22:58:18.148042+00', '2026-01-20 22:58:18.148042+00', '2026-01-20 22:58:18.148042+00'),
	('3cf15feb-b3d9-4d66-b034-7e6c4950a28a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 18, 2, 'medium', '', '2026-01-20 22:58:18.149209+00', '2026-01-20 22:58:18.149209+00', '2026-01-20 22:58:18.149209+00'),
	('ed4b5a3b-75cc-4312-9e25-81c19105494b', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'QDD-PRIV-MEDIA_BROADCAST-0031+news-nation', 2, 3, 'medium', '', '2026-01-20 22:58:18.172491+00', '2026-01-20 22:58:18.172491+00', '2026-01-20 22:58:18.172491+00'),
	('635322cd-04aa-48b8-a553-ce4d58982019', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 5, 5, 'medium', '', '2026-01-20 23:04:46.283764+00', '2026-01-20 23:05:58.961757+00', '2026-01-20 23:04:46.283764+00'),
	('4f148f31-4277-4f99-832d-0c586822699a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 16, 5, 'medium', '', '2026-01-20 23:04:46.397975+00', '2026-01-20 23:05:58.964715+00', '2026-01-20 23:04:46.397975+00'),
	('9fd0fb77-71e5-4184-afb9-41f09d2a3efe', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 6, 4, 'medium', '', '2026-01-20 23:04:46.40609+00', '2026-01-20 23:05:59.070113+00', '2026-01-20 23:04:46.40609+00'),
	('63a46ef2-b7ef-4c4e-a0db-0eafaf44fee2', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 12, 4, 'medium', '', '2026-01-20 23:04:46.405926+00', '2026-01-20 23:05:59.07099+00', '2026-01-20 23:04:46.405926+00'),
	('69801638-b8b1-4304-b87d-d43984b3f6af', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 19, 5, 'medium', '', '2026-01-20 23:04:46.343152+00', '2026-01-20 23:05:59.070347+00', '2026-01-20 23:04:46.343152+00'),
	('b72e32d1-de2e-4ef6-af4a-fe1db3fc3d00', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 8, 5, 'medium', '', '2026-01-20 23:04:46.339913+00', '2026-01-20 23:05:59.080061+00', '2026-01-20 23:04:46.339913+00'),
	('2272f34e-c0c9-4d11-9b1e-10d722ef9796', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 4, 4, 'medium', '', '2026-01-20 23:04:46.244502+00', '2026-01-20 23:05:59.087953+00', '2026-01-20 23:04:46.244502+00'),
	('cadde75f-5cbc-4ece-9967-a2c2ee51a2c9', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 13, 5, 'medium', '', '2026-01-20 23:04:46.39978+00', '2026-01-20 23:05:59.092959+00', '2026-01-20 23:04:46.39978+00'),
	('c2d7956a-6ed3-4410-892b-44e3cfa4c85e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 15, 4, 'medium', '', '2026-01-20 23:04:46.311222+00', '2026-01-20 23:05:59.093011+00', '2026-01-20 23:04:46.311222+00'),
	('56672bb9-55b5-4496-97db-8e7cc0ee1de8', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 3, 3, 'medium', '', '2026-01-20 23:04:46.399579+00', '2026-01-20 23:05:59.116183+00', '2026-01-20 23:04:46.399579+00'),
	('8a25ef7a-a052-48d2-bf94-2553f607c151', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'aaro-report-vol1-2024', 7, 4, 'medium', '', '2026-01-20 23:04:46.406249+00', '2026-01-20 23:05:59.157068+00', '2026-01-20 23:04:46.406249+00'),
	('99aa24a9-8546-4647-91f3-7518af5bc53e', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 2, 4, 'medium', '', '2026-01-20 23:35:09.743935+00', '2026-01-20 23:35:09.743935+00', '2026-01-20 23:35:09.743935+00'),
	('2bb2908e-2757-4f48-804f-0027c0365501', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 3, 4, 'medium', '', '2026-01-20 23:35:09.863746+00', '2026-01-20 23:35:09.863746+00', '2026-01-20 23:35:09.863746+00'),
	('786d2416-0549-4d48-aa0f-535ebc188d83', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 8, 4, 'medium', '', '2026-01-20 23:35:09.793752+00', '2026-01-20 23:35:09.793752+00', '2026-01-20 23:35:09.793752+00'),
	('7fde0172-8e9e-443f-90ac-c8aa1de78a18', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 5, 4, 'medium', '', '2026-01-20 23:35:09.943766+00', '2026-01-20 23:35:09.943766+00', '2026-01-20 23:35:09.943766+00'),
	('bcba90d3-4eef-4387-aa22-572c6792454d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'ilyumzhinov-interview-2023', 10, 5, 'medium', '', '2026-01-20 23:35:09.787075+00', '2026-01-20 23:35:09.787075+00', '2026-01-20 23:35:09.787075+00'),
	('08c2fcd8-5330-489d-879a-30b58ce498ea', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 1, 3, 'medium', '', '2026-01-24 04:36:22.754091+00', '2026-01-24 04:36:22.754091+00', '2026-01-24 04:36:22.754091+00'),
	('e1df7560-f8b9-4447-99a6-ed5136c4848d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 11, 4, 'medium', '', '2026-01-24 04:36:22.800989+00', '2026-01-24 04:36:22.800989+00', '2026-01-24 04:36:22.800989+00'),
	('b403ba40-9a2f-42fd-a284-eecfbda0e103', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 15, 4, 'medium', '', '2026-01-24 04:36:22.831149+00', '2026-01-24 04:36:22.831149+00', '2026-01-24 04:36:22.831149+00'),
	('c39cf7da-be3f-4f17-955f-e979dab1f794', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 7, 5, 'medium', '', '2026-01-24 04:36:22.877376+00', '2026-01-24 04:36:22.877376+00', '2026-01-24 04:36:22.877376+00'),
	('650bbc39-520e-4348-a03a-ec8778ba0d9a', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 6, 4, 'medium', '', '2026-01-24 04:36:22.904011+00', '2026-01-24 04:36:22.904011+00', '2026-01-24 04:36:22.904011+00'),
	('33458929-48b3-41c0-ad3a-8bec4f36a268', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 4, 4, 'medium', '', '2026-01-24 04:36:22.919823+00', '2026-01-24 04:36:22.919823+00', '2026-01-24 04:36:22.919823+00'),
	('69b2d66a-d4c9-4f58-b1b5-337f4ecf9cf6', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 10, 3, 'medium', '', '2026-01-24 04:36:22.924768+00', '2026-01-24 04:36:22.924768+00', '2026-01-24 04:36:22.924768+00'),
	('53277ef7-6cd1-4e72-aa67-6edf039f99e1', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'congressional-scif-jan-2024', 14, 4, 'medium', '', '2026-01-24 04:36:22.958304+00', '2026-01-24 04:36:22.958304+00', '2026-01-24 04:36:22.958304+00');


--
-- Data for Name: metric_discussions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."metric_discussions" ("id", "metric_id", "user_id", "comment", "parent_id", "created_at", "updated_at", "upvotes", "downvotes") VALUES
	('a38a89c5-0e62-4c1e-b25b-6c07585c7cb1', 13, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'sdfdsf', NULL, '2026-01-10 10:05:31.230873+00', '2026-01-10 10:05:31.230873+00', 0, 0),
	('4547cace-f681-420f-831e-06af6f440f5f', 16, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'on snap', NULL, '2026-01-10 10:05:48.751404+00', '2026-01-10 10:05:48.751404+00', 0, 0),
	('b27e0a03-4af5-46e4-9841-a81f0162d35c', 6, 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'sdds', NULL, '2026-01-10 12:59:05.832499+00', '2026-01-10 12:59:05.832499+00', 0, 0),
	('fd01df4e-408d-4c2f-bb80-9cf52425a322', 9, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'Bomboclaut
', NULL, '2026-01-10 14:17:02.095748+00', '2026-01-10 14:17:02.095748+00', 0, 0),
	('3741bb67-e03e-4b8a-a51a-3f9108151fd7', 17, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'fff', NULL, '2026-01-10 14:46:21.538694+00', '2026-01-10 14:46:21.538694+00', 0, 0),
	('de8fdd1f-dfb8-4b8b-85f3-9aad33815003', 5, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'ss', NULL, '2026-01-10 15:16:57.406061+00', '2026-01-10 15:16:57.406061+00', 0, 0),
	('ceab5a84-703b-4a0d-9c8a-e00707181334', 1, '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'sdf', NULL, '2026-01-10 21:24:04.569526+00', '2026-01-10 21:24:04.569526+00', 0, 0),
	('b262774f-786e-49d9-9412-9eb1ca3e6f29', 10, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'tttt', NULL, '2026-01-11 00:17:05.901235+00', '2026-01-11 00:17:05.901235+00', 0, 0),
	('42257572-4952-48f4-8835-d526f41e6b58', 10, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'sdfd', NULL, '2026-01-11 00:17:10.154443+00', '2026-01-11 00:17:10.154443+00', 0, 0),
	('ed4b7df9-1d9f-48bf-a206-52133a5a3c3d', 3, 'daf56408-129f-4ed7-9af5-1fefd84068ea', ' ewr', NULL, '2026-01-11 02:18:52.562801+00', '2026-01-11 02:18:52.562801+00', 0, 0),
	('cab82ec6-58b2-412d-9da0-d265708f2e36', 18, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'lmno p', NULL, '2026-01-11 02:19:12.799419+00', '2026-01-11 02:19:12.799419+00', 0, 0),
	('c32c28f5-b23f-49f7-b759-7e4eec0d34e4', 19, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'fycj uyeah
', NULL, '2026-01-11 03:06:30.521937+00', '2026-01-11 03:06:30.521937+00', 0, 0),
	('b09494ca-5e0b-43e5-b463-6c15d0a145d8', 14, '286f27d8-00a1-43c5-a855-0f8fe153c423', 'SSS', NULL, '2026-01-11 05:04:28.664488+00', '2026-01-11 05:04:28.664488+00', 0, 0),
	('25b63d85-586c-43a1-bbfc-56b50c2dec08', 2, '132fdb5d-3a06-406c-a87b-570b56028a4a', 'De Hello', NULL, '2026-01-11 06:10:08.039838+00', '2026-01-11 06:10:08.039838+00', 0, 0),
	('b37fd3e0-da4e-43c3-8e27-2509df6ab7bc', 2, '132fdb5d-3a06-406c-a87b-570b56028a4a', 'HIII', 'c35ddfdc-1a93-4707-86ce-dc325d34ded9', '2026-01-11 06:10:20.041893+00', '2026-01-11 06:10:20.041893+00', 0, 0),
	('bdc577ee-39df-4fd4-a389-9a8999fbf14d', 3, '132fdb5d-3a06-406c-a87b-570b56028a4a', 'Sigh', 'ed4b7df9-1d9f-48bf-a206-52133a5a3c3d', '2026-01-11 06:10:56.963621+00', '2026-01-11 06:10:56.963621+00', 0, 0),
	('0ba1a668-e9f5-4c53-b32c-d16edd3949f3', 3, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'ccc', NULL, '2026-01-11 02:18:56.942368+00', '2026-01-11 07:49:05.684043+00', 1, 0),
	('9de011d7-799a-443e-9ff3-3d9aa7de8ad5', 3, 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'sss', NULL, '2026-01-10 12:56:26.5384+00', '2026-01-11 07:52:31.485847+00', 0, 1),
	('fab1c14f-f337-4455-ba0d-a5348cfe3099', 3, 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'sdsdss', NULL, '2026-01-11 07:54:05.630259+00', '2026-01-11 07:54:18.278281+00', 1, 0),
	('7381c036-44af-4ef1-ba03-fc9ac35e801e', 3, 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'v ccc', NULL, '2026-01-11 07:54:28.028924+00', '2026-01-11 07:54:28.028924+00', 0, 0),
	('6d91512a-25a5-44f1-a5c9-c516ebae17c4', 4, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'AB', NULL, '2026-01-11 07:48:25.146943+00', '2026-01-11 07:58:42.195924+00', 0, 1),
	('c35ddfdc-1a93-4707-86ce-dc325d34ded9', 2, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'sdfsdd', NULL, '2026-01-10 14:07:33.701765+00', '2026-01-11 07:59:07.789871+00', 1, 0),
	('f367dad1-264c-49c6-a823-149dce8d361b', 2, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'bvvvvv', NULL, '2026-01-11 07:59:20.147515+00', '2026-01-11 07:59:54.852839+00', 1, 0),
	('6d3aefff-0234-4a64-a4bb-d2ce64308387', 2, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'erxc', NULL, '2026-01-11 07:59:47.479655+00', '2026-01-11 07:59:59.986607+00', 1, 0),
	('4e8f022f-cef4-4137-91d6-8dd8a030e6bb', 2, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'frtrtreetrtr', NULL, '2026-01-11 08:00:08.354397+00', '2026-01-11 08:00:08.354397+00', 0, 0),
	('e78dd782-428a-43d8-a00c-7be6b9646db9', 8, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'we', NULL, '2026-01-11 09:59:27.295758+00', '2026-01-11 09:59:27.295758+00', 0, 0),
	('8ba34cd0-50ca-4849-9582-b4564ae6011c', 8, 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'sssss', NULL, '2026-01-11 02:42:58.815268+00', '2026-01-11 09:59:29.14715+00', 1, 0);


--
-- Data for Name: discussion_votes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."discussion_votes" ("id", "discussion_id", "user_id", "vote_type", "created_at") VALUES
	('cb65808f-b67c-49c6-b493-07480bb7fb35', 'ceab5a84-703b-4a0d-9c8a-e00707181334', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'upvote', '2026-01-11 05:12:21.945911+00'),
	('9fa2c9f8-b6e4-452d-a061-f1cfe51ea5f7', '9de011d7-799a-443e-9ff3-3d9aa7de8ad5', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'upvote', '2026-01-11 06:10:29.828033+00'),
	('93dca10d-2027-4d1d-b64c-29fb30176e70', 'ed4b7df9-1d9f-48bf-a206-52133a5a3c3d', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'downvote', '2026-01-11 06:10:28.393692+00'),
	('81ee787a-0441-42a7-8f4e-4548ed81f167', 'ceab5a84-703b-4a0d-9c8a-e00707181334', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'downvote', '2026-01-11 07:44:41.923213+00'),
	('25bc1385-83f5-4773-a00e-8888e6012a2e', 'bdc577ee-39df-4fd4-a389-9a8999fbf14d', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 07:48:57.637199+00'),
	('46bcabb2-a2d2-4f2b-a933-7bd0c9d877b7', '0ba1a668-e9f5-4c53-b32c-d16edd3949f3', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 07:49:05.684043+00'),
	('7cf0c2e6-960a-4c9e-bdf4-85e2047c23ba', '9de011d7-799a-443e-9ff3-3d9aa7de8ad5', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 07:49:03.301283+00'),
	('84f25ea0-5491-429d-b963-a678f57c5f0e', '9de011d7-799a-443e-9ff3-3d9aa7de8ad5', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'downvote', '2026-01-11 07:52:28.033047+00'),
	('6b3f1793-78bc-46cc-b9bc-17a79982b422', '0ba1a668-e9f5-4c53-b32c-d16edd3949f3', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'upvote', '2026-01-11 07:53:55.327796+00'),
	('e5acfd03-8452-487c-ae51-e2243fab34b9', 'fab1c14f-f337-4455-ba0d-a5348cfe3099', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'upvote', '2026-01-11 07:54:18.278281+00'),
	('359e3b36-c0a6-4d03-a970-c24674d5eb9a', 'ed4b7df9-1d9f-48bf-a206-52133a5a3c3d', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'upvote', '2026-01-11 07:52:29.344917+00'),
	('566d5578-9a65-4bfd-932e-0c55a710f8c7', 'bdc577ee-39df-4fd4-a389-9a8999fbf14d', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'upvote', '2026-01-11 07:52:25.556473+00'),
	('9d4f5d11-6179-474b-bf4b-ad3ba603c58f', '6d91512a-25a5-44f1-a5c9-c516ebae17c4', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'downvote', '2026-01-11 07:48:27.429666+00'),
	('e18c5596-4b63-497b-b032-c2439e888c64', 'c35ddfdc-1a93-4707-86ce-dc325d34ded9', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 07:59:07.694375+00'),
	('db892de8-2caa-4f63-8389-7951696e29f8', 'b37fd3e0-da4e-43c3-8e27-2509df6ab7bc', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'downvote', '2026-01-11 07:59:03.507832+00'),
	('6ebe5b94-81f7-4a73-9234-534631e674fe', 'f367dad1-264c-49c6-a823-149dce8d361b', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 07:59:54.852839+00'),
	('2781cc07-7c3e-4daa-a28a-572624c0a5c6', '6d3aefff-0234-4a64-a4bb-d2ce64308387', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 07:59:59.986607+00'),
	('f4b0bd1f-56f8-48b4-af06-336a967b1255', '25b63d85-586c-43a1-bbfc-56b50c2dec08', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'downvote', '2026-01-11 07:59:13.758172+00'),
	('23081d54-18a0-49f7-92c1-8af8fef044fc', '8ba34cd0-50ca-4849-9582-b4564ae6011c', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'upvote', '2026-01-11 09:59:29.14715+00'),
	('7f33222c-4ca4-44d5-b9cd-e93f6a5a592a', 'ceab5a84-703b-4a0d-9c8a-e00707181334', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'upvote', '2026-01-11 10:38:52.010677+00');


--
-- Data for Name: new_metric_proposals; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: metric_proposal_votes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: metric_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: protocol_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."protocol_config" ("id", "config_key", "config_value", "description", "updated_at", "updated_by") VALUES
	(1, 'protocol_version', '001', 'Current QDD Protocol version number (3-digit format)', '2026-01-09 17:28:00.612011+00', NULL);


--
-- Data for Name: rfc_votes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: saved_searches; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: search_history; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: target_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_preferences" ("id", "user_id", "last_viewed_tab", "sidebar_collapsed", "theme", "saved_filters", "email_notifications", "discussion_notifications", "rfc_notifications", "items_per_page", "show_consensus_overlay", "created_at", "updated_at", "selected_category_filter", "search_query") VALUES
	('cd6459a9-a2ad-44e7-aec4-1b85293b712d', 'a5734ec1-210b-4ee0-92f1-d0a99a280713', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-10 17:15:39.123617+00', '2026-01-10 17:15:39.123617+00', 'all', ''),
	('f4557132-ccfc-4f62-a6d7-7e51f71ebf1d', '2bcf4386-383c-4fdd-8c4b-311bc6a85a77', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-10 18:51:56.639561+00', '2026-01-10 18:51:56.639561+00', 'all', ''),
	('33269733-2489-4342-bd74-505551ce789e', '15a0e973-4b17-4d14-aef4-3ee1f768ba44', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-10 18:52:15.41499+00', '2026-01-10 18:52:15.41499+00', 'all', ''),
	('40d563c4-de46-4e30-af42-a39a53e52ec0', '73caa1d9-455a-43ce-ba81-f2b37242e748', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:02:57.791966+00', '2026-01-11 04:02:57.791966+00', 'all', ''),
	('f522bd67-edf5-4053-8b20-db36f49aeb21', '2ceae342-cc8c-46c4-a6fd-b625f4471f8a', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:07:23.412418+00', '2026-01-11 04:07:23.412418+00', 'all', ''),
	('84880455-ac23-49ec-ae09-009849560fa2', '8af556c0-d504-4f0d-99b5-aadfbe9a7107', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:19:38.271783+00', '2026-01-11 04:19:38.271783+00', 'all', ''),
	('34adad3c-087e-4a21-bc62-3076fedae0e6', 'd27f7741-bf91-4c6d-82bc-27b6e79284fb', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:43:11.341627+00', '2026-01-11 04:43:11.341627+00', 'all', ''),
	('34621e6f-560f-4a39-b933-fda428acfd78', '7ddcaff5-b8e0-47cf-b904-3b9a53c37c41', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:47:09.493817+00', '2026-01-11 04:47:09.493817+00', 'all', ''),
	('01922c2b-6e36-4fd0-a813-8cca52bf4e6f', '286f27d8-00a1-43c5-a855-0f8fe153c423', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:48:08.903409+00', '2026-01-11 04:48:08.903409+00', 'all', ''),
	('24ff21de-4296-4ae6-9e3a-1c858e7c95bb', '29df7fd8-624c-4103-bc83-8c7d6e85c0e0', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-11 04:54:03.681089+00', '2026-01-11 04:54:03.681089+00', 'all', ''),
	('19fdfb38-a1fb-4154-b96b-165f2506d652', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-15 03:51:42.620822+00', '2026-01-15 03:51:42.620822+00', 'all', ''),
	('97405b84-7e2c-4604-8294-48ce076bdbbf', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-15 03:51:42.620822+00', '2026-01-15 03:51:42.620822+00', 'all', ''),
	('c9d3832c-10b9-442a-8b7b-4a7b846d2f08', '132fdb5d-3a06-406c-a87b-570b56028a4a', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-15 03:51:42.620822+00', '2026-01-15 03:51:42.620822+00', 'all', ''),
	('ab1bed37-44f2-4b00-b332-a17d2e413baf', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-15 03:51:42.620822+00', '2026-01-15 03:51:42.620822+00', 'all', ''),
	('75024212-799c-45f4-8520-f1adcf0fc5db', '4f308a61-8fde-4783-b1a6-4f1712061da5', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-15 03:55:36.373476+00', '2026-01-15 03:55:36.373476+00', 'all', ''),
	('544c6310-af62-44ba-adb9-21e56ea4ec56', '9a5e5ad6-f9be-465a-a27f-a6f5a6679bfa', NULL, false, 'dark', '{}', true, true, true, 20, true, '2026-01-28 06:03:15.881412+00', '2026-01-28 06:03:15.881412+00', 'all', '');


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_profiles" ("id", "user_id", "role", "full_name", "created_at", "updated_at", "avatar_url", "bio", "location", "website", "is_verified", "contributor_id", "pseudonym", "anonymous", "last_pseudonym_change", "allow_public_profile", "show_in_leaderboard", "oauth_provider", "oauth_handle", "oauth_verified", "oauth_verified_at", "oauth_profile_url", "beta_features_enabled") VALUES
	('075a53bf-6f75-44de-a5eb-e47fe4992353', '05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'user', 'Randy Moncrief', '2026-01-15 03:51:42.620822+00', '2026-01-23 08:39:28.874059+00', NULL, NULL, NULL, NULL, false, 'QDD-00014', 'BoldWatcher038', true, '2026-01-15 03:51:42.620822+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('d3d79833-61fb-4248-bf2b-9ab4cea9b445', '9a5e5ad6-f9be-465a-a27f-a6f5a6679bfa', 'user', 'appreview', '2026-01-28 06:03:15.881412+00', '2026-01-28 06:03:15.881412+00', NULL, NULL, NULL, NULL, false, 'QDD-00017', 'BraveObserver645', true, '2026-01-28 06:03:15.881412+00', true, true, 'email', NULL, false, NULL, NULL, false),
	('1398554d-3348-4ee4-9eed-338586e9c4ae', 'a5734ec1-210b-4ee0-92f1-d0a99a280713', 'user', 'Evan Meeks', '2026-01-10 17:15:39.123617+00', '2026-01-10 17:15:39.123617+00', NULL, NULL, NULL, NULL, false, 'QDD-00001', 'QuickScholar560', true, '2026-01-10 17:15:39.123617+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('f7fd048a-7c6b-4e1a-bcf3-9f9f5b0ec21c', '73caa1d9-455a-43ce-ba81-f2b37242e748', 'user', 'evan.m.eeks', '2026-01-11 04:02:57.791966+00', '2026-01-11 04:02:57.791966+00', NULL, NULL, NULL, NULL, false, 'QDD-00002', 'ClearObserver827', true, '2026-01-11 04:02:57.791966+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('1bde5fbe-cd82-48dc-84ac-0928cefe6261', '2ceae342-cc8c-46c4-a6fd-b625f4471f8a', 'user', 'evan.m.e+eks', '2026-01-11 04:07:23.412418+00', '2026-01-11 04:07:23.412418+00', NULL, NULL, NULL, NULL, false, 'QDD-00003', 'SwiftDecoder119', true, '2026-01-11 04:07:23.412418+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('d67c1d4c-b078-4c9e-9c73-ce025388f806', '8af556c0-d504-4f0d-99b5-aadfbe9a7107', 'user', 'hell.o', '2026-01-11 04:19:38.271783+00', '2026-01-11 04:19:38.271783+00', NULL, NULL, NULL, NULL, false, 'QDD-00004', 'SilentSignal118', true, '2026-01-11 04:19:38.271783+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('c41732bb-78bd-451b-9ed9-0da4cf42bf55', '29df7fd8-624c-4103-bc83-8c7d6e85c0e0', 'user', 'e.van.mee.k.s', '2026-01-11 04:54:03.681089+00', '2026-01-11 04:54:03.681089+00', NULL, NULL, NULL, NULL, false, 'QDD-00005', 'KeenCipher835', true, '2026-01-11 04:54:03.681089+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('67b98378-67fc-46f0-8254-ae49848bd12a', 'd9eb0f55-dea4-4659-b277-e300f6eddbbf', 'user', 'Evan Meeks', '2026-01-15 03:51:42.620822+00', '2026-01-15 03:51:42.620822+00', NULL, NULL, NULL, NULL, false, 'QDD-00012', 'KeenSentinel031', true, '2026-01-15 03:51:42.620822+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('65c15896-7b49-4bae-917f-7beac72d0bde', 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'user', 'Evan Meeks', '2026-01-15 03:51:42.620822+00', '2026-01-15 03:51:42.620822+00', NULL, NULL, NULL, NULL, false, 'QDD-00013', 'SilentScholar881', true, '2026-01-15 03:51:42.620822+00', true, true, NULL, NULL, false, NULL, NULL, false),
	('e2e6bbff-ede1-4be9-94cf-fdc86046a25e', '286f27d8-00a1-43c5-a855-0f8fe153c423', 'admin', 'ed209.m+', '2026-01-11 04:48:08.903409+00', '2026-01-11 14:18:51.446939+00', NULL, NULL, NULL, NULL, false, 'QDD-00006', 'BrightVector707', true, '2026-01-11 04:48:08.903409+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('29cd84ba-199a-4119-b9c4-5fae59bc688e', '15a0e973-4b17-4d14-aef4-3ee1f768ba44', 'admin', 'hello', '2026-01-10 18:52:15.41499+00', '2026-01-11 14:19:20.921946+00', NULL, NULL, NULL, NULL, false, 'QDD-00007', 'DeepDecoder800', true, '2026-01-10 18:52:15.41499+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('852c953b-a05a-498b-9afe-74e05b0c8684', 'daf56408-129f-4ed7-9af5-1fefd84068ea', 'admin', NULL, '2026-01-10 07:13:46.378561+00', '2026-01-10 07:13:46.378561+00', NULL, NULL, NULL, NULL, false, 'QDD-00008', 'CalmRanger190', true, '2026-01-10 07:13:46.378561+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('b734668b-fdf7-421f-b666-23c1d477421d', '7ddcaff5-b8e0-47cf-b904-3b9a53c37c41', 'contributor', 'e.van.meeks', '2026-01-11 04:47:09.493817+00', '2026-01-13 09:28:40.422318+00', NULL, NULL, NULL, NULL, false, 'QDD-00009', 'SwiftDecoder428', true, '2026-01-11 04:47:09.493817+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('e5525d25-d94c-46e9-8b85-254e2b0728f5', 'd27f7741-bf91-4c6d-82bc-27b6e79284fb', 'contributor', 'e.vanmeeks', '2026-01-11 04:43:11.341627+00', '2026-01-13 10:12:56.860162+00', NULL, NULL, NULL, NULL, false, 'QDD-00010', 'SwiftWitness708', true, '2026-01-11 04:43:11.341627+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('4d749c31-1aef-4212-a3b0-2d753ba3a000', '2bcf4386-383c-4fdd-8c4b-311bc6a85a77', 'contributor', 'fade.to.bass', '2026-01-10 18:51:56.639561+00', '2026-01-15 00:29:13.678698+00', NULL, NULL, NULL, NULL, false, 'QDD-00011', 'BoldScanner247', true, '2026-01-10 18:51:56.639561+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('3d3b3cd1-74a9-499a-92ac-f78c725e3c77', '4f308a61-8fde-4783-b1a6-4f1712061da5', 'contributor', 'fadeto.bass', '2026-01-15 03:55:36.373476+00', '2026-01-19 19:42:15.962242+00', NULL, NULL, NULL, NULL, false, 'QDD-00015', 'SharpScanner259', true, '2026-01-15 03:55:36.373476+00', true, true, NULL, NULL, false, NULL, NULL, true),
	('fa63dfc8-ff7e-4d86-a3bb-262af760a9e5', '132fdb5d-3a06-406c-a87b-570b56028a4a', 'admin', 'Clark Kent', '2026-01-15 03:51:42.620822+00', '2026-01-22 06:04:32.144925+00', NULL, NULL, NULL, NULL, false, 'QDD-00016', 'BoldDecoder484', true, '2026-01-15 03:51:42.620822+00', true, true, NULL, NULL, false, NULL, NULL, true);


--
-- Data for Name: user_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_scores" ("id", "user_id", "target_id", "metric_id", "score", "notes", "created_at", "updated_at", "action_vote", "action_notes", "confidence_level", "score_type", "last_updated_at") VALUES
	('b6ba9a11-78f8-4cd8-a309-18df85f013b8', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 6, 0, '', '2026-01-20 18:31:12.363508+00', '2026-01-20 18:31:11.008+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.363508+00'),
	('0d19ebb7-968f-4b0f-bea3-87012d0eb300', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 2, 0, '', '2026-01-20 18:31:12.366551+00', '2026-01-20 18:31:10.718+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.366551+00'),
	('40b6c7e9-8a47-4d05-8117-233898b5a708', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 3, 0, '', '2026-01-20 18:31:12.363286+00', '2026-01-20 18:31:10.791+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.363286+00'),
	('99207904-2ef0-4ef7-af0f-2b7502419ec6', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 4, 0, '', '2026-01-20 18:31:12.45891+00', '2026-01-20 18:31:10.862+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.45891+00'),
	('4439cfb9-1be0-4cae-accd-1010f852b306', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 5, 0, '', '2026-01-20 18:31:12.48478+00', '2026-01-20 18:31:10.939+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.48478+00'),
	('fc6ed9f1-397e-43d1-8c8f-6622636b4224', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 10, 0, '', '2026-01-20 18:31:12.499545+00', '2026-01-20 18:31:11.386+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.499545+00'),
	('a8ab7246-2182-487b-8406-ec485f61878b', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 8, 4, '', '2026-01-20 18:31:12.536511+00', '2026-01-20 18:31:11.225+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.536511+00'),
	('c8c5c1ba-4e74-45ba-8abb-4ff0efcff46a', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 11, 0, '', '2026-01-20 18:31:12.542722+00', '2026-01-20 18:31:11.452+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.542722+00'),
	('9c6f033b-fac3-4459-9808-63ac0b368540', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 12, 0, '', '2026-01-20 18:31:12.544086+00', '2026-01-20 18:31:11.522+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.544086+00'),
	('a9648236-98d3-4177-b1a0-1eafea5166fe', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 19, 0, '', '2026-01-20 18:31:12.544405+00', '2026-01-20 18:31:12.197+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.544405+00'),
	('df8299ad-5862-4ec6-94db-31e2ae645795', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 13, 0, '', '2026-01-20 18:31:12.544332+00', '2026-01-20 18:31:11.673+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.544332+00'),
	('a63a74fa-a57c-47c9-9e93-f26421b3f596', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 1, 4, '', '2026-01-20 18:31:12.562223+00', '2026-01-20 18:31:10.64+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.562223+00'),
	('9fa441ff-e727-4070-87a9-700881eabc42', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 16, 0, '', '2026-01-20 18:31:12.563088+00', '2026-01-20 18:31:11.897+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.563088+00'),
	('db7e71a3-7901-47fe-8675-0863c21da7cf', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 9, 0, '', '2026-01-20 18:31:12.565067+00', '2026-01-20 18:31:11.294+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.565067+00'),
	('e2f5fde1-2b75-414e-b647-810e1c91f969', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 18, 0, '', '2026-01-20 18:31:12.563336+00', '2026-01-20 18:31:12.045+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.563336+00'),
	('a9196bb4-bc46-4d88-8567-f3771af1b62a', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 15, 0, '', '2026-01-20 18:31:12.576414+00', '2026-01-20 18:31:11.818+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.576414+00'),
	('09efd852-908d-4922-b135-84be2730769a', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 17, 0, '', '2026-01-20 18:31:12.577027+00', '2026-01-20 18:31:11.971+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.577027+00'),
	('a829fa0e-03cf-4995-a8a0-9594c042869b', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 14, 0, '', '2026-01-20 18:31:12.578875+00', '2026-01-20 18:31:11.748+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.578875+00'),
	('8a3c3f4b-ff3e-46a1-bf3d-7270acf1e1a5', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 7, 0, '', '2026-01-20 18:31:12.579965+00', '2026-01-20 18:31:11.149+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.579965+00'),
	('9ca3399a-a523-4eda-890c-90605afca5b5', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 20, 0, '', '2026-01-20 18:31:12.603581+00', '2026-01-20 18:31:12.273+00', NULL, NULL, NULL, 'slider', '2026-01-20 18:31:12.603581+00');


--
-- Data for Name: user_score_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_score_history" ("id", "user_score_id", "user_id", "target_id", "metric_id", "score", "notes", "action_vote", "action_notes", "change_type", "changed_at") VALUES
	('59bc341b-cde1-4ee8-93c9-6c15af06c0a2', '0d19ebb7-968f-4b0f-bea3-87012d0eb300', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 2, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.366551+00'),
	('a9a31a91-47c7-43e4-ab6e-8d48105dc040', 'a8ab7246-2182-487b-8406-ec485f61878b', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 8, 4, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.536511+00'),
	('e5e2619c-db45-490e-b0d4-584969df0888', 'a63a74fa-a57c-47c9-9e93-f26421b3f596', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 1, 4, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.562223+00'),
	('de3f18ec-dcc4-41d6-92da-f94ca0c97296', 'a829fa0e-03cf-4995-a8a0-9594c042869b', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 14, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.578875+00'),
	('baaa5c58-c4d1-4842-aa73-83bf60dfbe2f', '40b6c7e9-8a47-4d05-8117-233898b5a708', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 3, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.363286+00'),
	('5c746b6b-88aa-463d-97ae-b4fa21654ac5', 'c8c5c1ba-4e74-45ba-8abb-4ff0efcff46a', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 11, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.542722+00'),
	('fa262947-c98c-4dfa-b0cb-d36194d50d6e', '9fa441ff-e727-4070-87a9-700881eabc42', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 16, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.563088+00'),
	('e2388af4-78d2-4ddf-8472-eaae70a4875e', '09efd852-908d-4922-b135-84be2730769a', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 17, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.577027+00'),
	('fde627d3-46cc-461c-a1f8-8182640cd8cf', 'b6ba9a11-78f8-4cd8-a309-18df85f013b8', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 6, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.363508+00'),
	('65a3cae9-872c-41ba-b7bf-0a4327dd5cf8', '99207904-2ef0-4ef7-af0f-2b7502419ec6', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 4, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.45891+00'),
	('7a0d521a-5f5a-4e04-b479-807d6863ce3a', '4439cfb9-1be0-4cae-accd-1010f852b306', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 5, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.48478+00'),
	('2179b6be-568e-4756-a1d0-89ed997991ef', 'fc6ed9f1-397e-43d1-8c8f-6622636b4224', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 10, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.499545+00'),
	('b538a12d-df3c-411c-a41b-92cc81120c32', '9c6f033b-fac3-4459-9808-63ac0b368540', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 12, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.544086+00'),
	('87029b51-9ccf-4b37-89ff-de46953a2e49', 'a9648236-98d3-4177-b1a0-1eafea5166fe', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 19, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.544405+00'),
	('ec494288-5a42-4d90-99e3-470cc1d344ec', 'df8299ad-5862-4ec6-94db-31e2ae645795', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 13, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.544332+00'),
	('76479848-db60-4543-bfb0-1d881fa092b3', 'db7e71a3-7901-47fe-8675-0863c21da7cf', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 9, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.565067+00'),
	('c3255887-b6f3-4829-8223-593eed7f356b', 'e2f5fde1-2b75-414e-b647-810e1c91f969', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 18, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.563336+00'),
	('530095ee-f862-46df-8df5-a212da7af9d6', 'a9196bb4-bc46-4d88-8567-f3771af1b62a', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 15, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.576414+00'),
	('fed594f6-eb1e-4734-833e-2b7a3d16e871', '8a3c3f4b-ff3e-46a1-bf3d-7270acf1e1a5', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 7, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.579965+00'),
	('b08281cb-8f4c-403c-8923-07d0912c7c49', '9ca3399a-a523-4eda-890c-90605afca5b5', '132fdb5d-3a06-406c-a87b-570b56028a4a', '114141214414', 20, 0, '', NULL, NULL, 'full_update', '2026-01-20 18:31:12.603581+00');


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: vote_rationales; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets_analytics" ("name", "type", "format", "created_at", "updated_at", "id", "deleted_at") VALUES
	('qdd-d-analyitcs', 'ANALYTICS', 'ICEBERG', '2026-01-20 20:28:33.292604+00', '2026-01-20 20:28:33.292604+00', 'b0418475-182d-4cf1-a119-b30d8485612f', NULL);


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 372, true);


--
-- Name: case_id_ref_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."case_id_ref_seq"', 32, true);


--
-- Name: contributor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."contributor_id_seq"', 17, true);


--
-- Name: metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."metrics_id_seq"', 20, true);


--
-- Name: protocol_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."protocol_config_id_seq"', 2, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict xAM2dVKVoTkeQMWy4tQma8SWPLTluQfZCZcgfbcEMwP9wsfDiUJI7ftZCONvltz

RESET ALL;
