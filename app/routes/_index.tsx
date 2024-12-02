import type { MetaFunction} from "@remix-run/node";
import { useLoaderData } from "@remix-run/react";

export const meta: MetaFunction = () => {
  return [
    { title: "New Remix App" },
    { name: "description", content: "Welcome to Remix!" },
  ];
};

export const loader = async() => {
  return {date: new Date().toLocaleDateString('fr-FR'), APP_ENV: process.env.APP_ENV}
}


export default function Index() {
  const {date, APP_ENV} = useLoaderData<typeof loader>();
  return (
    <div className="flex h-screen items-center justify-center">
        {date}
        <img src="https://picsum.photos/1366/768" alt="" />
        <p style={{backgroundColor: APP_ENV === 'production' ? "pink" : "yellow", color: "black"}}>{APP_ENV}</p>
    </div>
  );
}
