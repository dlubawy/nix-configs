<script lang="ts">
	let count = 0;
	const increment = () => {
		count += 1;
	};
</script>

<main>
	<a href="https://vite.dev" target="_blank" rel="noreferrer">Vite</a>
	<a href="https://svelte.dev" target="_blank" rel="noreferrer">Svelte</a>
</main>

<h1>Hello Vite + Svelte!</h1>

<button onclick={increment}>count is {count}</button>

<p>Edit <code>src/App.svelte</code> and save to test HMR.</p>
