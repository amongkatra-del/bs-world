import { useEffect, useState } from "react";
import { View, Text, ActivityIndicator, StyleSheet } from "react-native";
import { useLocalSearchParams, router } from "expo-router";
import { supabase } from "@/lib/supabase";
import { theme } from "@/lib/theme";

export default function AuthCallback() {
  const params = useLocalSearchParams();
  const [message, setMessage] = useState("Confirming your account…");

  useEffect(() => {
    let mounted = true;

    async function confirmAccount() {
      try {
        const code =
          typeof params.code === "string"
            ? params.code
            : Array.isArray(params.code)
            ? params.code[0]
            : null;

        if (!code) {
          if (mounted) {
            setMessage("Confirmation link is invalid or expired.");
          }
          return;
        }

        const { error } = await supabase.auth.exchangeCodeForSession(code);

        if (error) {
          if (mounted) {
            setMessage(error.message);
          }
          return;
        }

        if (mounted) {
          setMessage("Account confirmed successfully!");

          setTimeout(() => {
            router.replace("/home");
          }, 800);
        }
      } catch (error) {
        if (mounted) {
          setMessage(
            error instanceof Error
              ? error.message
              : "Something went wrong."
          );
        }
      }
    }

    confirmAccount();

    return () => {
      mounted = false;
    };
  }, [params.code]);

  return (
    <View style={styles.container}>
      <Text style={styles.brand}>
        bs<Text style={styles.dot}>.</Text>world
      </Text>

      <ActivityIndicator
        size="large"
        color={theme.purple}
        style={styles.loader}
      />

      <Text style={styles.message}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.bg,
    alignItems: "center",
    justifyContent: "center",
    padding: 24,
  },

  brand: {
    color: "#fff",
    fontSize: 40,
    fontWeight: "800",
    marginBottom: 35,
  },

  dot: {
    color: theme.purple,
  },

  loader: {
    marginBottom: 25,
  },

  message: {
    color: "#fff",
    fontSize: 16,
    textAlign: "center",
    lineHeight: 24,
  },
});
