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
