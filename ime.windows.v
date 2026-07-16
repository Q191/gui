#flag windows -limm32
struct C.POINT {
mut:
	x int
	y int
}
struct C.COMPOSITIONFORM {
mut:
	dwStyle      u32
	ptCurrentPos C.POINT
	rcArea       voidptr
}
fn C.ImmGetContext(hwnd voidptr) voidptr
fn C.ImmSetCompositionWindow(himc voidptr, form &C.COMPOSITIONFORM) bool
fn C.ImmReleaseContext(hwnd voidptr, himc voidptr) bool
const cfs_point = u32(0x0002)
fn set_ime_position(hwnd voidptr, x int, y int) {
	println([x, y])
	if hwnd == unsafe { nil } {
		return
	}
	$if windows {
		himc := C.ImmGetContext(hwnd)
		if himc != unsafe { nil } {
			mut windows_ime_form := C.COMPOSITIONFORM{
				dwStyle: cfs_point
				ptCurrentPos: C.POINT{
					x: x
					y: y
				}
				rcArea: unsafe { nil }
			}
			C.ImmSetCompositionWindow(himc, &windows_ime_form)
			C.ImmReleaseContext(hwnd, himc)
		}
	}
}
// IME holds per-window Input Method Editor state.
// Created lazily because the native window is not ready during
// init_fn.
struct IME {
mut:
	overlay     voidptr = unsafe { nil }
	handler     voidptr = unsafe { nil }
	initialized bool
}

// ime_create_overlay creates the platform-specific IME overlay.
// Returns nil on platforms without IME overlay support.
fn ime_create_overlay() voidptr {
	$if macos {
		ns_window := sapp.macos_get_window()
		if ns_window == unsafe { nil } {
			return unsafe { nil }
		}
		return vglyph.ime_overlay_create_auto(ns_window)
	} $if windows {
		hwnd := sapp.win32_get_hwnd()
		if hwnd == unsafe { nil } {
			return unsafe { nil }
		}
		return hwnd
	} $else {
		// Linux: vglyph stubs return nil (no overlay yet).
		return unsafe { nil }
	}
}
