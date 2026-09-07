import { useState } from "react";
import { router } from "expo-router";
import { View, Text, TextInput, Pressable, StyleSheet, Alert } from "react-native";
import { supabase } from "@/lib/supabase";
import { theme } from "@/lib/theme";

export default function Signup() {
  const [name, setName] = useState("");
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);

  async function create() {
    if (!name || !username || !email || !password) {
      return Alert.alert("Check details", "Enter all fields.");
    }

    if (password.length < 6) {
      return Alert.alert("Password", "Password must be at least 6 characters.");
    }

    setBusy(true);

    const { error } = await supabase.auth.signUp({
      email: email.trim(),
      password,
      options: {
        data: {
          display_name: name.trim(),
          username: username.trim().toLowerCase(),
        },
      },
    });

    setBusy(false);

    if (error) {
      return Alert.alert("Sign up failed", error.message);
    }

    Alert.alert(
      "Account created",
      "Check your email to confirm your account.",
      [
        {
          text: "OK",
          onPress: () => router.replace("/login"),
        },
      ]
    );
  }

  return (
    <View style={s.root}>
      <Text style={s.brand}>bs<Text style={{ color: theme.purple }}>.</Text>world</Text>

      <Text style={s.title}>Create account</Text>

      <TextInput
        style={s.input}
        placeholder="Full name"
        placeholderTextColor={theme.muted}
        value={name}
        onChangeText={setName}
      />

      <TextInput
        style={s.input}
        placeholder="Username"
        placeholderTextColor={theme.muted}
        value={username}
        onChangeText={setUsername}
        autoCapitalize="none"
      />

      <TextInput
        style={s.input}
        placeholder="Email"
        placeholderTextColor={theme.muted}
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
      />

      <TextInput
        style={s.input}
        placeholder="Password"
        placeholderTextColor={theme.muted}
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />

      <Pressable
        style={s.button}
        onPress={create}
        disabled={busy}
      >
        <Text style={s.buttonText}>
          {busy ? "Creating..." : "Sign Up"}
        </Text>
      </Pressable>

      <Pressable onPress={() => router.replace("/login")}>
        <Text style={s.link}>Already have an account? Log in</Text>
      </Pressable>
    </View>
  );
}

const s = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: theme.bg,
    padding: 24,
    justifyContent: "center",
  },
  brand: {
    fontSize: 40,
    fontWeight: "800",
    color: "#fff",
    textAlign: "center",
    marginBottom: 35,
  },
  title: {
    color: "#fff",
    fontSize: 26,
    fontWeight: "800",
    marginBottom: 20,
  },
  input: {
    height: 54,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: theme.border,
    backgroundColor: theme.card,
    color: "#fff",
    paddingHorizontal: 16,
    marginTop: 10,
  },
  button: {
    height: 54,
    borderRadius: 15,
    backgroundColor: theme.purple,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 18,
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "800",
  },
  link: {
    color: "#B990FF",
    textAlign: "center",
    marginTop: 20,
    fontSize: 16,
  },
});
